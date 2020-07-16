import VisualAppBase

// TODO: implement rendering render objects! --> check out flutter and other frameworks
// --> + a render graph api or something like that
// TODO: also keep an immediate render renderer / functional buffer renderer (NanoVG style / canvas api style)
// TODO: maybe have RenderObjectRenderStrategy instead??
public class RenderObjectRenderer {
    
    
    public init() {
    }

    // TODO: maybe do layering via z?
    public func render(_ backendRenderer: Renderer, _ renderObject: RenderObject, _ previousTree: RenderObject? = nil) throws {
        switch (renderObject) {
        case let renderObject as RenderObject.Container:
            for child in renderObject.children {
                try render(backendRenderer, child)
            }
        case let renderObject as RenderObject.Custom:
            try renderObject.render(backendRenderer)
        case let renderObject as RenderObject.RenderStyle:
            try render(backendRenderer, renderObject.child)
            if let fillColor = renderObject.renderStyle.fillColor {
                try backendRenderer.fillColor(fillColor)
                try backendRenderer.fill()
            }
            if let strokeWidth = renderObject.renderStyle.strokeWidth,
                let strokeColor = renderObject.renderStyle.strokeColor {
                try backendRenderer.strokeWidth(strokeWidth)
                try backendRenderer.strokeColor(strokeColor)
                try backendRenderer.stroke()
            }
            // TODO: after render, reset style to style that was present before
        case let renderObject as RenderObject.Rect:
            try backendRenderer.beginPath()
            try backendRenderer.rect(renderObject.rect)
        case let renderObject as RenderObject.Text:
            if renderObject.textConfig.wrap {
                try backendRenderer.multilineText(renderObject.text, topLeft: renderObject.topLeft, maxWidth: renderObject.maxWidth ?? 0, fontConfig: renderObject.textConfig.fontConfig, color: renderObject.textConfig.color)
            } else {
                try backendRenderer.text(renderObject.text, topLeft: renderObject.topLeft, fontConfig: renderObject.textConfig.fontConfig, color: renderObject.textConfig.color)
            }
        default:
            print("Could not render RenderObject, implementation missing for.", renderObject)
        }
    }
}

public struct RenderState {
    
}