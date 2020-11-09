import Foundation
import CustomGraphicsMath

public class ImmediateRenderObjectTreeRenderer: RenderObjectTreeRenderer {
    public let tree: RenderObjectTree
    private let context: ApplicationContext
    public var rerenderNeeded = true
    private var destroyed = false
    private let sliceRenderer: RenderObjectTreeSliceRenderer
    private var treeMessageBuffer: [RenderObject.UpwardMessage] = []
    private var activeTransitionCount = 0

    private var removeBusHandler: (() -> ())? = nil

    required public init(_ tree: RenderObjectTree, context: ApplicationContext) {
        self.tree = tree
        self.context = context
        self.sliceRenderer = RenderObjectTreeSliceRenderer(context: context)
        
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
            case .TransitionStarted:
                //activeTransitionCount += 1
                break
            case .TransitionEnded:
                //activeTransitionCount -= 1
                break
            case .ChildrenUpdated:
                rerenderNeeded = true
            default:
                break
            }
        }
        if activeTransitionCount > 0 {
            rerenderNeeded = true
        }
        treeMessageBuffer = []
    }

    public func render(with backendRenderer: Renderer, in bounds: DRect) {
        sliceRenderer.render(RenderObjectTree.TreeSlice(tree: tree, start: TreePath(), end: TreePath()), with: backendRenderer)
        rerenderNeeded = false
    }

    public func destroy() {
        sliceRenderer.destroy()
        if let remove = removeBusHandler {
            remove()
        }
        destroyed = true
    }
}