import VisualAppBase
import GfxMath
import Path
import Foundation

// TODO: maybe give rendering an extra package outside of VisualAppBase
public class OptimizingRenderObjectTreeRenderer: RenderObjectTreeRenderer {
    public private(set) var tree: RenderObjectTree
    private let context: ApplicationContext
    private var treeMessageBuffer: [RenderObject.UpwardMessage] = []

    public var debuggingData: DebuggingData {
        DebuggingData(tree: tree, sequence: [])
    }

    private var groups: [RenderGroup] = []
    private var groupMessageBuffer: [RenderGroup.Message] = []
    public private(set) var rerenderNeeded = true
    private var sliceRenderer: RenderObjectTreeSliceRenderer
    private var destroyed = false
    
    required public init(_ tree: RenderObjectTree, treeSliceRenderer: RenderObjectTreeSliceRenderer, context: ApplicationContext) {
        self.tree = tree
        self.context = context
        self.sliceRenderer = treeSliceRenderer
        _ = self.tree.bus.onUpwardMessage { [unowned self] in
            treeMessageBuffer.append($0)
        }
    }

    deinit {
        if !destroyed {
            fatalError("deinitialized before destroy() was called")
        }
    }

    public func tick(_ tick: Tick) {
        for message in treeMessageBuffer {
            processTreeMessage(message)
        }

        treeMessageBuffer = []
        
        // TODO: the processTreeMessage can also have lead to multiple
        // calls to makeGroups()
        // make a flag or so and call it after the processTreeMessage in this
        // function here one time
        if groups.count == 0 {
            makeGroups()
        }

        for group in groups {
            group.tick()
        }

        for message in groupMessageBuffer {
            processGroupMessage(message)
        }

        groupMessageBuffer = []
    }

    private func makeGroups() {
        groups = []
        var currentPath = TreePath()
        var currentNode: RenderObject = tree
        var nextGroupStart = TreePath()

        outer: while true {
            // TODO: refine conditions for cache split
            if let currentNode = currentNode as? CacheSplitRenderObject {
                groups.append(RenderGroup(slices: [RenderObjectTree.TreeSlice(tree: tree, start: nextGroupStart, end: currentPath)]))
                print("MADE NEW GROUP FROM", nextGroupStart, "TO", currentPath)
                nextGroupStart = currentPath
            }

            if currentNode.isBranching, currentNode.children.count > 0 {
                currentPath = currentPath/0
                currentNode = currentNode.children[0]
            } else {
                var currentParent = currentNode.parent
                while currentParent != nil {
                    if currentParent!.children.count > currentPath.last! + 1 {
                        currentPath = currentPath + 1
                        currentNode = currentParent!.children[currentPath.last!]
                        continue outer
                    } else {
                        currentPath = currentPath.dropLast()
                        currentParent = currentParent?.parent       
                    }
                }

                break
            }
        }

        self.groups.append(
            RenderGroup(slices: [RenderObjectTree.TreeSlice(tree: tree, start: nextGroupStart, end: TreePath())]))

        for group in groups {
            _ = group.onMessage { [unowned self] in
                groupMessageBuffer.append($0)
            }
        }

        print("MADE", self.groups.count, "groups")
    }

    private func processTreeMessage(_ message: RenderObject.UpwardMessage) {
        //print("RECEIVED MESSAGE FORM TREE", message, message.sender.treePath)
        for group in groups {
            for slice in group.slices {
                if slice.contains(message.sender.treePath) {
                    group.processBusMessage(message)
                    break
                }
            }
        }

        switch message.content {
        case .childrenUpdated:
            groups = []

        default:
            break
        }
    }

    private func processGroupMessage(_ message: RenderGroup.Message) {
        switch message {
        case .ChildrenUpdated:
            makeGroups()
        case .RerenderNeeded:
            rerenderNeeded = true
        }
    }

    public func render(with backendRenderer: Renderer, in bounds: DRect) {
        for group in groups {
            render(group: group, with: backendRenderer, in: bounds)
        }
        
        rerenderNeeded = false
    }

    // TODO: check whether inline is good for performance
    private func render(group: RenderGroup, with backendRenderer: Renderer, in bounds: DRect) {
        var group = group

        if group.cachable {
            if let cache = group.cache {
                if cache.size != bounds.size {
                    group.cache = nil
                }
            }

            print("GROUP IS CACHABLE")

            if group.cache == nil {
                print("GROUP HAS NO CACHE")
                // TODO: maybe set screen size to group size
                let cache = backendRenderer.makeVirtualScreen(size: bounds.size)
                backendRenderer.pushVirtualScreen(cache)
                backendRenderer.beginFrame()
                
                for slice in group.slices {
                    render(slice: slice, with: backendRenderer)
                }
                
                backendRenderer.endFrame()
                backendRenderer.popVirtualScreen()
                group.cache = cache
            }

            if let cache = group.cache {
                print("GROUP HAS CACHE, render from cache")
                backendRenderer.beginFrame()
                backendRenderer.drawVirtualScreens([cache], at: [DVec2.zero])
                backendRenderer.endFrame()
            }
        } else {
            print("GROUP IS NOT CACHABLE")
            backendRenderer.beginFrame()
            for slice in group.slices {
                render(slice: slice, with: backendRenderer)
            }            
            backendRenderer.endFrame()
        }
    }

    private func render(slice: RenderObjectTree.TreeSlice, with backendRenderer: Renderer) {
        sliceRenderer.render(slice, with: backendRenderer)
    }

    public func destroy() {
        // TODO: cleanup
    }
}

extension OptimizingRenderObjectTreeRenderer {
    public class RenderGroup {
        public var slices: [RenderObjectTree.TreeSlice]
        public var activeTransitionCount = 0
        public var cachable: Bool {
            activeTransitionCount == 0
        }
        public var cache: VirtualScreen? = nil
        public internal(set) var onMessage = EventHandlerManager<Message>()
        
        public init(slices: [RenderObjectTree.TreeSlice]) {
            self.slices = slices
        }

        public func processBusMessage(_ message: RenderObject.UpwardMessage) {
            print("RENDER GROUP RECEIVED BUS message!", message, "from", message.sender)
            switch message.content {
            case .childrenUpdated:
                cache = nil
                onMessage.invokeHandlers(.RerenderNeeded)
            case .transitionStarted:
                activeTransitionCount += 1
            case .transitionEnded:
                activeTransitionCount -= 1
            case .addUncachable:
                fatalError("unhandled: .addUncachable")
            case .removeUncachable:
                fatalError("unhandled: .removeUncachable")
            }
        }

        public func tick() {
            if !cachable {
                cache = nil
            }
        }

        public enum Message {
            case ChildrenUpdated, RerenderNeeded
        }
    }

    public struct DebuggingData {
        public var tree: RenderObjectTree
        public var sequence: [RenderGroup]
        public init(tree: RenderObjectTree, sequence: [RenderGroup]) {
            self.tree = tree
            self.sequence = sequence
        }
    }
}
