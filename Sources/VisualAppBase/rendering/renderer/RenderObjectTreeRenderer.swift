import CustomGraphicsMath

public protocol RenderObjectTreeRenderer {

    var tree: RenderObjectTree { get }

    init(_ tree: RenderObjectTree)

    func render(with backendRenderer: Renderer, in bounds: DRect)
}