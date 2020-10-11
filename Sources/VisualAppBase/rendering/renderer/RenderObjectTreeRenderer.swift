import CustomGraphicsMath

public protocol RenderObjectTreeRenderer {

    var tree: RenderObjectTree { get }

    var rerenderNeeded: Bool { get }

    init(_ tree: RenderObjectTree)

    func tick(_ tick: Tick)

    func render(with backendRenderer: Renderer, in bounds: DRect)

    func destroy()
}