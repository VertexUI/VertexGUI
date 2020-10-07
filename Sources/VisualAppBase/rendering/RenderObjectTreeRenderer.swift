import VisualAppBase
import CustomGraphicsMath
import Path
import Foundation

// TODO: maybe give rendering an extra package outside of VisualAppBase
// TODO: maybe rename to RenderObjectTreeRenderer?
// TODO: maybe have a RenderObjectTreeGroupGenerator with efficientUpdate(identified: ...) etc. + a group renderer?
// TODO: create a RenderState --> contains RenderObjectTree, Transitions and more depending on RenderStrategy, maybe
public class RenderObjectTreeRenderer {

    private var tree: RenderObjectTree

    private var treeMessageBuffer: [RenderObject.UpwardMessage] = []

    public var debuggingData: DebuggingData {

        DebuggingData(tree: tree, sequence: [])
    }

    private var groups: [RenderGroup] = []

    private var groupMessageBuffer: [RenderGroup.Message] = []

    private var renderObjectMeta: [ObjectIdentifier: Any] = [:]
    
    public init(_ tree: RenderObjectTree) {
         
        self.tree = tree

        _ = self.tree.bus.onUpwardMessage { [unowned self] in

            self.treeMessageBuffer.append($0)
        }
    }

    public func tick() {

        for message in treeMessageBuffer {

            processTreeMessage(message)
        }

        treeMessageBuffer = []

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

        // TODO: forward tree message to group that contains the sender

        switch message.content {

        case .ChildrenUpdated:

            groups = []

        default:

            break
        }
    }

    private func processGroupMessage(_ message: RenderGroup.Message) {

        switch message {
        
        case .ChildrenUpdated:

            makeGroups()
        }
    }

    public func render(with backendRenderer: Renderer, in bounds: DRect) {
        
        for group in groups {

            render(group: group, with: backendRenderer, in: bounds)
        }
    }

    // TODO: check whether inline is good for performance
    private func render(group: RenderGroup, with backendRenderer: Renderer, in bounds: DRect) {
        
        var group = group

        if group.cachable {

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
 
        var currentPath = slice.startPath

        var renderedNodeCount = 0

        outer: while let currentNode = slice[currentPath] {

            renderedNodeCount += 1

            if currentNode.isBranching, currentNode.children.count > 0 {

                renderOpen(node: currentNode, with: backendRenderer)
            
                currentPath = currentPath/0

            } else {

                if currentNode.isBranching {
            
                    renderClose(node: currentNode, with: backendRenderer)

                } else {
                    
                    renderLeaf(node: currentNode, with: backendRenderer)
                }

                var currentParent: RenderObject? = currentNode.parent

                var currentChildPath = currentPath

                while currentParent != nil {

                    renderClose(node: currentParent!, with: backendRenderer)

                    if currentParent!.children.count > currentChildPath.last! + 1 {

                        currentPath = currentChildPath + 1

                        continue outer
                    }

                    currentChildPath = currentChildPath.dropLast()

                    currentParent = currentParent?.parent
                }

                break
            }
        }
    }

    private func renderOpen(node: RenderObject, with backendRenderer: Renderer) {
        
        let timestamp = Date.timeIntervalSinceReferenceDate

        switch node {

        case let node as RenderStyleRenderObject:
            // TODO: implement tracking current render style as layers, whenever moving out of a child render style,
            // need to reapply the next parent
           // var performFill = false
           // var performStroke = false

            if let fillRenderValue = node.fill {

                let fill = fillRenderValue.getValue(at: timestamp)

                if fillRenderValue.isTimed {

                    switch fill {

                    case let .Color(value):

                        backendRenderer.fillColor(value)

                    case let .Image(value, position):

                        backendRenderer.fillImage(value, position: position)
                    }

                } else {
                    
                    switch fill {

                    case let .Color(value):

                        backendRenderer.fillColor(value)
                    
                    case let .Image(value, position):

                        let id = ObjectIdentifier(node)
                        
                        if let cachedLoadedFill = renderObjectMeta[id] as? LoadedFill {
                       
                           backendRenderer.applyFill(cachedLoadedFill)
                      
                        } else {
                           
                            let loadedFill = backendRenderer.fillImage(value, position: position)
                           
                            renderObjectMeta[id] = loadedFill
                        }
                    }
                }

               // performFill = true

            } else {

                backendRenderer.fillColor(.Transparent)
            }

            if let strokeWidth = node.strokeWidth,

                let strokeColor = node.strokeColor {

                backendRenderer.strokeWidth(strokeWidth)

                backendRenderer.strokeColor(strokeColor.getValue(at: timestamp))

               // performStroke = true
            } else {

                backendRenderer.strokeWidth(0)

                backendRenderer.strokeColor(.Transparent)
            }

        case let node as RenderObject.Translation:

            backendRenderer.translate(node.translation)

        case let node as RenderObject.Clip:

            // TODO: right now, clip areas can't be nested --> implement clip area bounds stack

            backendRenderer.clipArea(bounds: node.clipBounds)

        default: 

            break
        }
    }

    private func renderClose(node: RenderObject, with backendRenderer: Renderer) {

        switch node {

        case let node as RenderStyleRenderObject:

            backendRenderer.fillColor(.Transparent)

            backendRenderer.strokeWidth(0)

            backendRenderer.strokeColor(.Transparent)

        case let node as TranslationRenderObject:

            backendRenderer.translate(-node.translation)

        case let node as ClipRenderObject:

            backendRenderer.releaseClipArea()

        default:

            break
        }
    }

    private func renderLeaf(node: RenderObject, with backendRenderer: Renderer) {

        switch node {

        case let node as RectangleRenderObject:

            backendRenderer.beginPath()

            if let cornerRadii = node.cornerRadii {

                backendRenderer.roundedRectangle(node.rect, cornerRadii: cornerRadii)

            } else {

                backendRenderer.rectangle(node.rect)
            }

            backendRenderer.fill()

            backendRenderer.stroke()
 
        case let node as CustomRenderObject:

            // TODO: this might be a dirty solution
            backendRenderer.endFrame()

            node.render(backendRenderer)

            backendRenderer.beginFrame()

        case let node as EllipsisRenderObject:

            backendRenderer.beginPath()

            backendRenderer.ellipse(node.bounds)

            backendRenderer.fill()

            backendRenderer.stroke()

        case let node as LineSegmentRenderObject:

            backendRenderer.beginPath()

            backendRenderer.lineSegment(from: node.start, to: node.end)
            
            backendRenderer.stroke()
            
            backendRenderer.fill()

        case let node as PathRenderObject:

            backendRenderer.beginPath()

            backendRenderer.path(node.path)

            backendRenderer.fill()

            backendRenderer.stroke()

        case let node as RenderObject.Text:

            backendRenderer.text(node.text, fontConfig: node.fontConfig, color: node.color, topLeft: node.topLeft, maxWidth: node.maxWidth)

        default:

            break
        }
    }
}

extension RenderObjectTreeRenderer {

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

            print("RENDER GROUP RECEIVED BUS message!", message)

            switch message.content {

            case .ChildrenUpdated:

                cache = nil

            case .TransitionStarted:

                activeTransitionCount += 1

            case .TransitionEnded:

                activeTransitionCount -= 1
            }
        }

        public func tick() {

            if !cachable {

                cache = nil
            }
        }

        public enum Message {

            case ChildrenUpdated
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