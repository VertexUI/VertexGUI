import VisualAppBase
import GfxMath
import CnanovgGL3

open class SDL2OpenGL3NanoVGDrawingContext: DrawingContext {
  private let nvg: UnsafeMutablePointer<NVGcontext>

  private var fontIds = [String: Int32]()

  public init(surface: DrawingSurface, nvg: UnsafeMutablePointer<NVGcontext>) {
    self.nvg = nvg
    super.init(surface: surface)
  }

  override open func clone() -> DrawingContext {
    return SDL2OpenGL3NanoVGDrawingContext(surface: surface, nvg: nvg)
  }

  override public func beginDrawing() {
    nvgBeginFrame(nvg, Float(surface.size.width), Float(surface.size.height), Float(surface.resolution))
  }

  override open func _drawRect(rect: DRect, paint: Paint) {
    if let color = paint.color {
      nvgFillColor(nvg, color.toNVG())
    }
    nvgRect(
      nvg,
      Float(rect.min.x),
      Float(rect.min.y),
      Float(rect.size.width),
      Float(rect.size.height))
    nvgFill(nvg)
  }

  override open func _measureText(text: String, paint: TextPaint) -> DSize2 {
    /*applyFontConfig(fontConfig)

    var bounds = [Float](repeating: 0, count: 4)

    if let maxWidth = maxWidth {
        nvgTextBoxBounds(window.nvg, 0, 0, Float(maxWidth), text, nil, &bounds)
    } else {
        nvgTextBounds(window.nvg, 0, 0, text, nil, &bounds)
    }

    return DSize2(Double(bounds[2]), Double(bounds[3]))*/
    .zero
  }

  override open func _drawText(text: String, position: DVec2, paint: TextPaint) {
    nvgBeginPath(nvg)
    applyFontConfig(paint.fontConfig)
    if let color = paint.color {
      nvgFillColor(nvg, color.toNVG())
    }

    if let breakWidth = paint.breakWidth {
        nvgTextBox(nvg, Float(position.x), Float(position.y), Float(breakWidth), text, nil)
    } else {
        nvgText(nvg, Float(position.x), Float(position.y), text, nil)
    }
  }

  private func applyFontConfig(_ config: FontConfig) {
    if fontIds[config.face.path] == nil {
        _ = loadFont(config.face.path)
    }
    nvgFontFaceId(nvg, fontIds[config.face.path]!)
    nvgFontSize(nvg, Float(config.size))
    nvgTextAlign(nvg, Int32(NVG_ALIGN_LEFT.rawValue | NVG_ALIGN_TOP.rawValue))
  }

  private func loadFont(_ path: String) -> Bool {
    let id = nvgCreateFont(nvg, path, path)
    if id > -1 {
        fontIds[path] = id
    }
    print("Loaded font from", path, id)
    return id > -1
  }

  override public func endDrawing() {
    nvgEndFrame(nvg)
  }
}