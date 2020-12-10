import Foundation
import GfxMath

// TODO: maybe should rename this to something with RenderStrategy and only keep TreeSliceRenderer with Renderer as main type name
public class ImmediateRenderObjectTreeRenderer: RenderObjectTreeRenderer {
    public let tree: RenderObjectTree
    private let context: ApplicationContext
    public var rerenderNeeded = true
    private var destroyed = false
    private let sliceRenderer: RenderObjectTreeSliceRenderer
    private var treeMessageBuffer: [RenderObject.UpwardMessage] = []
    private var uncachableElements: Set<ObjectIdentifier> = []
    private var activeTransitionCount = 0

    private var removeBusHandler: (() -> ())? = nil

    required public init(_ tree: RenderObjectTree, treeSliceRenderer: RenderObjectTreeSliceRenderer, context: ApplicationContext) {
        self.tree = tree
        self.context = context
        self.sliceRenderer = treeSliceRenderer
        
        // TODO: introduce pipes for tree bus as well
        removeBusHandler = self.tree.bus.onUpwardMessage({ [unowned self] in
            treeMessageBuffer.append($0)
        })
    }

    deinit {
        if !destroyed {
            fatalError("deinitialized before destroy() was called")
        }
    }

    public func tick(_ tick: Tick) {
        for message in treeMessageBuffer {
            switch message.content {
            case .invalidateCache:
                rerenderNeeded = true
            case .transitionStarted:
                //activeTransitionCount += 1
                break
            case .transitionEnded:
                //activeTransitionCount -= 1
                break
            case .addUncachable:
                uncachableElements.insert(ObjectIdentifier(message.sender))
            case .removeUncachable:
                uncachableElements.remove(ObjectIdentifier(message.sender))
            case .childrenUpdated:
                rerenderNeeded = true
            default:
                break
            }
        }
        if activeTransitionCount > 0 {
            rerenderNeeded = true
        }
        if uncachableElements.count > 0 {
            rerenderNeeded = true
        }
        treeMessageBuffer = []
    }

    public func render(with backendRenderer: Renderer, in bounds: DRect) {
        sliceRenderer.render(RenderObjectTree.TreeSlice(tree: tree, start: TreePath(), end: TreePath()), with: backendRenderer)
        if activeTransitionCount == 0 && uncachableElements.count == 0 {
            rerenderNeeded = false
        } else {
            rerenderNeeded = true
        }
    }

    public func destroy() {
        sliceRenderer.destroy()
        if let remove = removeBusHandler {
            remove()
        }
        destroyed = true
    }
}