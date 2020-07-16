import CustomGraphicsMath

// TODO: implement function for checking whether render object has content at certain position (--> is not transparent) --> used for mouse events like click etc.
public protocol RenderObject {
    typealias Container = VisualAppBase.ContainerRenderObject
    typealias RenderStyle = VisualAppBase.RenderStyleRenderObject
    typealias Rect = VisualAppBase.RectRenderObject
    typealias Custom = VisualAppBase.CustomRenderObject
    typealias Text = VisualAppBase.TextRenderObject
}

public struct ContainerRenderObject: RenderObject {
    public var children: [RenderObject]

    public init(_ children: [RenderObject]) {
        self.children = children
    }
}

public struct RenderStyleRenderObject: RenderObject {
    public var renderStyle: RenderStyle
    public var child: RenderObject

    public init(_ renderStyle: RenderStyle, _ child: RenderObject) {
        self.renderStyle = renderStyle
        self.child = child
    }
}

public struct RectRenderObject: RenderObject {
    public var rect: DRect
    
    public init(_ rect: DRect) {
        self.rect = rect
    }
}

public struct CustomRenderObject: RenderObject {
    public var render: (_ renderer: Renderer) throws -> Void

    public init(_ render: @escaping (_ renderer: Renderer) throws -> Void) {
        self.render = render
    }
}

public struct IdentifiedSubtreeRenderObject: RenderObject {
    public var id: Int

    public init(_ id: Int) {
        self.id = id
    }
}

//public struct CacheableRenderObject: RenderObject {
//
//}

public struct TextRenderObject: RenderObject {
    public var text: String
    public var topLeft: DVec2
    public var textConfig: TextConfig
    public var maxWidth: Double?    

    public init(_ text: String, topLeft: DVec2, textConfig: TextConfig, maxWidth: Double?) {
        self.text = text
        self.topLeft = topLeft
        self.textConfig = textConfig
        self.maxWidth = maxWidth
    }
}
/*public enum RenderObject {
    case Custom(_ render: (_ renderer: Renderer) throws -> Void)
    indirect case Container(_ children: [Self])
}*/