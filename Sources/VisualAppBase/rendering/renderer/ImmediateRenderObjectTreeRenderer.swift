import CustomGraphicsMath

public class ImmediateRenderObjectTreeRenderer: RenderObjectTreeRenderer {

    public let tree: RenderObjectTree

    public let rerenderNeeded = true

    required public init(_ tree: RenderObjectTree) {

        self.tree = tree
    }

    public func render(with backendRenderer: Renderer, in bounds: DRect) {

        print("RENDER!")
    }
}