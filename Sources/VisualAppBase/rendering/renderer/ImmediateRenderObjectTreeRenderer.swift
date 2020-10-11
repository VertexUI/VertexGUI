import Foundation
import CustomGraphicsMath

public class ImmediateRenderObjectTreeRenderer: RenderObjectTreeRenderer {

    public let tree: RenderObjectTree

    public let rerenderNeeded = true
    
    private var destroyed = false

    private let sliceRenderer = RenderObjectTreeSliceRenderer()

    required public init(_ tree: RenderObjectTree) {

        self.tree = tree
    }

    deinit {

        if !destroyed {

            fatalError("deinitialized before destroy() was called")
        }
    }

    public func tick(_ tick: Tick) {

    }

    public func render(with backendRenderer: Renderer, in bounds: DRect) {

        sliceRenderer.render(RenderObjectTree.TreeSlice(tree: tree, start: TreePath(), end: TreePath()), with: backendRenderer)
    } 

    public func destroy() {}
}