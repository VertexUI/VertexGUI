import CustomGraphicsMath

public protocol RenderObjectTreeRenderer: class {
    var tree: RenderObjectTree { get }
    var rerenderNeeded: Bool { get }

    init(_ tree: RenderObjectTree, treeSliceRenderer: RenderObjectTreeSliceRenderer, context: ApplicationContext)

    func tick(_ tick: Tick)

    func render(with backendRenderer: Renderer, in bounds: DRect)

    func destroy()
}