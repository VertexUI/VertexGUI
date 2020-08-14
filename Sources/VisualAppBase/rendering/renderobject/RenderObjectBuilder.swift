@_functionBuilder
public struct RenderObjectBuilder {


    /*public static func buildExpression(_ renderObject: RenderObject) -> RenderObject {
        return renderObject
    }*/

    public static func buildExpression(_ renderObjects: [RenderObject?]) -> [RenderObject] {
        return renderObjects.compactMap { $0 }
    }

    public static func buildExpression(_ renderObjects: [RenderObject]) -> [RenderObject] {
        return renderObjects.compactMap { $0 }
    }

    public static func buildExpression(_ renderObject: RenderObject) -> [RenderObject] {
        return [renderObject].compactMap { $0 }
    }

    public static func buildExpression(_ renderObject: RenderObject?) -> [RenderObject] {
        return [renderObject].compactMap { $0 }
    }




    /*public static func buildExpression(_ renderObjects: RenderObject...) -> [RenderObject] {
        return renderObjects.compactMap { $0 }
    }*/
 
    /*public static func buildExpression(_ renderObjects: [RenderObject]) -> [RenderObject] {
        return renderObjects.flatMap { $0 }.compactMap { $0 }
    }*/
    /*public static func buildBlock(_ renderObjects: RenderObject?...) -> [RenderObject] {
        return renderObjects.compactMap { $0 }
    }*/

    public static func buildBlock(_ renderObjects: [RenderObject]) -> [RenderObject] {
        return renderObjects
    }
    /*
    public static func buildBlock(_ renderObject: RenderObject) -> [RenderObject] {
        return [renderObject].compactMap { $0 }
    }*/
/*
    public static func buildBlock(_ renderObjects: RenderObject?...) -> [RenderObject] {
        return renderObjects.compactMap { $0 }
    }*/
    
    public static func buildBlock(_ renderObjects: [RenderObject]...) -> [RenderObject] {
        return renderObjects.flatMap { $0 }.compactMap { $0 }
    }

    /*public static func buildBlock(_ renderObject: RenderObject) -> RenderObject {
        return renderObject
    }*/

    /*public static func buildBlock(_ renderObject: RenderObject) -> [RenderObject] {
        return [renderObject]
    }*/
/*
    public static func buildBlock(_ renderObjects: [RenderObject]) -> [RenderObject] {
        return renderObjects.compactMap { $0 }
    }*/

  /*  public static func buildOptional(_ renderObject: RenderObject?) -> RenderObject {
        return renderObject != nil ? renderObject! : RenderObject.Container([])
    }*/

    public static func buildOptional(_ renderObjects: [RenderObject]?) -> [RenderObject] {
        return renderObjects ?? []
    }

    /*public static func buildOptional(_ renderObjects: [RenderObject?]) -> [RenderObject] {
        return renderObjects.compactMap { $0 }
    }*/

    public static func buildEither(first: RenderObject) -> RenderObject {
        return first
    }

    public static func buildEither(first: [RenderObject]) -> [RenderObject] {
        return first
    }

    public static func buildEither(second: RenderObject) -> RenderObject {
        return second
    }

    public static func buildEither(second: [RenderObject]) -> [RenderObject] {
        return second
    }


    public static func buildArray(_ renderObjects: [RenderObject]) -> [RenderObject] {
        return renderObjects
    }

    public static func buildArray(_ renderObjects: [[RenderObject]]) -> [RenderObject] {
        return renderObjects.flatMap { $0 }
    }

    /*public static func buildOptional(_ renderObject: [RenderObject?]) -> [RenderObject?] {
        return renderObject
    }*/

    /*public static func buildEither(first: [RenderObject]) -> [RenderObject] {
        return first
    }

    public static func buildEither(second: [RenderObject]) -> [RenderObject] {
        return second
    }*/
}