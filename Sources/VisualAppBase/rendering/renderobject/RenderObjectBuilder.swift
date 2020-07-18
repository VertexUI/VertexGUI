@_functionBuilder
public struct RenderObjectBuilder {
    public static func buildBlock(_ renderObject: RenderObject) -> RenderObject {
        return renderObject
    }

    public static func buildBlock(_ renderObjects: RenderObject...) -> [RenderObject] {
        return Array(renderObjects)
    }
}