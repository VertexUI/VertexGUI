import CustomGraphicsMath
import VisualAppBase

public protocol RenderObject {
    typealias Container = WidgetGUI.ContainerRenderObject
    typealias RenderStyle = WidgetGUI.RenderStyleRenderObject
    typealias Rect = WidgetGUI.RectRenderObject
    typealias Custom = WidgetGUI.CustomRenderObject
    typealias Text = WidgetGUI.TextRenderObject
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