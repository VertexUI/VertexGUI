@_functionBuilder
public struct RenderObjectBuilder {
    public static func buildBlock(_ renderObject: RenderObject) -> RenderObject {
        return renderObject
    }

    public static func buildBlock(_ renderObject: RenderObject) -> [RenderObject] {
        return [renderObject]
    }

    public static func buildBlock(_ renderObjects: RenderObject?...) -> [RenderObject] {
        return Array(renderObjects.compactMap { $0 })
    }

    public static func buildOptional(_ renderObject: RenderObject?) -> RenderObject? {
        return renderObject
    }

    public static func buildEither(first: RenderObject) -> RenderObject {
        return first
    }

    public static func buildEither(second: RenderObject) -> RenderObject {
        return second
    }
}