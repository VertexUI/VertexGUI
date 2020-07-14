import CSDL2
import GL
import Cnanovg
import CustomGraphicsMath
import GLGraphicsMath
import VisualAppBase

open class SDL2OpenGL3NanoVGRenderer: Renderer {
    /*open class var vectorLayout: VectorLayout2<DVec2> {
        .topLeftToBottomRight
    }*/
    
    // TODO: maybe this has to be put into System? or does NanoVG load it into the current gl state???
    private var fontIds = [String: Int32]()

    private var window: SDL2OpenGL3NanoVGWindow

    /*public var resolution: Double {
        window.drawableSize.width / window.size.width
    }*/

    public init(window: SDL2OpenGL3NanoVGWindow) {
        self.window = window
    }

    public var nvg: UnsafeMutablePointer<NVGcontext> {
        get {
            window.nvg
        }
    }

    private func loadFont(_ path: String) -> Bool {
        let id = nvgCreateFont(window.nvg, path, path)
        if id > -1 {
            fontIds[path] = id
        }
        print("Loaded font from", path, id)
        return id > -1
    }

    open func clear(_ color: Color) throws {
        GL.glClearColor(color.glR, color.glG, color.glB, color.glA)
        GL.glClear(GLMap.COLOR_BUFFER_BIT)
    }

    open func beginFrame() throws {
        SDL_GL_MakeCurrent(window.sdlWindow, window.glContext)
        glViewport(x: 0, y: 0, width: GLMap.Size(window.drawableSize.width), height: GLMap.Size(window.drawableSize.height))
        nvgBeginFrame(window.nvg, Float(window.size.width), Float(window.size.height), window.pixelRatio)
    }

    open func endFrame() throws {
	    nvgEndFrame(window.nvg)
    }

    open func beginPath() throws {
        nvgBeginPath(window.nvg)
    }

    open func fillColor(_ color: Color) throws {
        nvgFillColor(window.nvg, color.toNVG())
    }

    open func fill() throws {
        nvgFill(window.nvg)
    }

    open func rect(_ rect: DRect) throws {
        //nvgBeginPath(window.nvg)
        nvgRect(window.nvg, Float(rect.topLeft.x), Float(rect.topLeft.y), Float(rect.size.width), Float(rect.size.height))
        //if let fillColor = style.fillColor {
        //    nvgFillColor(window.nvg, fillColor.toNVG())
        //    nvgFill(window.nvg)
        //}
    }

    open func line(from: DPoint2, to: DPoint2, width: Double, color: Color) throws {
        nvgBeginPath(window.nvg)
        nvgMoveTo(window.nvg, Float(from.x), Float(from.y))
        nvgLineTo(window.nvg, Float(to.x), Float(to.y))
        nvgStrokeWidth(window.nvg, Float(width))
        nvgStrokeColor(window.nvg, color.toNVG())
        nvgStroke(window.nvg)
    }

    open func circle(center: DPoint2, radius: Double, style: RenderStyle) throws {
        nvgBeginPath(window.nvg)
        nvgCircle(window.nvg, Float(center.x), Float(center.y), Float(radius))
        if let fillColor = style.fillColor {
            nvgFillColor(window.nvg, fillColor.toNVG())
            nvgFill(window.nvg)
        }
    }

    public func ellipse(center: DPoint2, radius: DVec2, style: RenderStyle) throws {
        fatalError("ellipse not implemented")
    }

    private func applyFontConfig(_ config: FontConfig) {
        if fontIds[config.face.path] == nil {
            loadFont(config.face.path)
        }
        nvgFontFaceId(window.nvg, fontIds[config.face.path]!)
        nvgFontSize(window.nvg, Float(config.size))
        nvgTextAlign(window.nvg, Int32(NVG_ALIGN_LEFT.rawValue | NVG_ALIGN_TOP.rawValue))
    }

    open func text(_ text: String, topLeft: DPoint2, fontConfig: FontConfig, color: Color) throws {
        nvgBeginPath(window.nvg)
        applyFontConfig(fontConfig)
        nvgFillColor(window.nvg, color.toNVG())
        nvgText(window.nvg, Float(topLeft.x), Float(topLeft.y), text, nil)
    }

    open func getTextBoundsSize(_ text: String, fontConfig: FontConfig) throws -> DSize2 {
        applyFontConfig(fontConfig)
        var bounds = [Float](repeating: 0, count: 4)
        nvgTextBounds(window.nvg, 0, 0, text, nil, &bounds)
        return DSize2(Double(bounds[2]), Double(bounds[3]))
    }

    open func multilineText(_ text: String, topLeft: DPoint2, maxWidth: Double, fontConfig: FontConfig, color: Color) throws {
        nvgBeginPath(window.nvg)
        applyFontConfig(fontConfig)
        nvgFillColor(window.nvg, color.toNVG())
        nvgTextBox(window.nvg, Float(topLeft.x), Float(topLeft.y), Float(maxWidth), text, nil)
    }

    open func getMultilineTextBoundsSize(_ text: String, maxWidth: Double, fontConfig: FontConfig) throws -> DSize2 {
        applyFontConfig(fontConfig)
        var bounds = [Float](repeating: 0, count: 4)
        nvgTextBoxBounds(window.nvg, 0, 0, Float(maxWidth), text, nil, &bounds)
        return DSize2(Double(bounds[2]), Double(bounds[3]))
    }

    open func globalOpacity(_ opacity: Float) throws {
        nvgGlobalAlpha(window.nvg, opacity)
    }

    open func clipArea(bounds: DRect) throws {
        nvgScissor(window.nvg, Float(bounds.topLeft.x), Float(bounds.topLeft.y), Float(bounds.size.width), Float(bounds.size.height))
    }

    open func releaseClipArea() throws {
        nvgResetScissor(window.nvg)
    }

    open func scale(_ amount: DVec2) throws {
        nvgScale(window.nvg, Float(amount.x), Float(amount.y))
    }

    open func translate(_ translation: DVec2) throws {
        nvgTranslate(window.nvg, Float(translation.x), Float(translation.y))
    }

    open func resetTransform() {
        nvgResetTransform(window.nvg)
    }

    /*open func flush() throws {
        SDL_GL_SwapWindow(window.sdlWindow)
    }*/
}