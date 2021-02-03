import VisualAppBase
import GfxMath
import CnanovgGL3

open class SDL2OpenGL3NanoVGDrawingBackend: DrawingBackend {
  private let surface: SDL2OpenGL3NanoVGDrawingSurface

  private var fontIds = [String: Int32]()

  public init(surface: SDL2OpenGL3NanoVGDrawingSurface) {
    self.surface = surface
  }

  override public func activate() {
    nvgBeginFrame(surface.nvg, Float(surface.size.width), Float(surface.size.height), Float(surface.resolution))
  }

  override open func drawRect(rect: DRect, paint: Paint) {
    if let color = paint.color {
      nvgFillColor(surface.nvg, color.toNVG())
    }
    nvgRect(
      surface.nvg,
      Float(rect.min.x),
      Float(rect.min.y),
      Float(rect.size.width),
      Float(rect.size.height))
    nvgFill(surface.nvg)
  }

  override open func measureText(text: String, paint: TextPaint) -> DSize2 {
    /*applyFontConfig(fontConfig)

    var bounds = [Float](repeating: 0, count: 4)

    if let maxWidth = maxWidth {
        nvgTextBoxBounds(window.surface.nvg, 0, 0, Float(maxWidth), text, nil, &bounds)
    } else {
        nvgTextBounds(window.surface.nvg, 0, 0, text, nil, &bounds)
    }

    return DSize2(Double(bounds[2]), Double(bounds[3]))*/
    .zero
  }

  override open func drawText(text: String, position: DVec2, paint: TextPaint) {
    nvgBeginPath(surface.nvg)
    applyFontConfig(paint.fontConfig)
    if let color = paint.color {
      nvgFillColor(surface.nvg, color.toNVG())
    }

    if let breakWidth = paint.breakWidth {
        nvgTextBox(surface.nvg, Float(position.x), Float(position.y), Float(breakWidth), text, nil)
    } else {
        nvgText(surface.nvg, Float(position.x), Float(position.y), text, nil)
    }
  }

  private func applyFontConfig(_ config: FontConfig) {
    if fontIds[config.face.path] == nil {
      _ = loadFont(config.face.path)
    }
    nvgFontFaceId(surface.nvg, fontIds[config.face.path]!)
    nvgFontSize(surface.nvg, Float(config.size))
    nvgTextAlign(surface.nvg, Int32(NVG_ALIGN_LEFT.rawValue | NVG_ALIGN_TOP.rawValue))
  }

  private func loadFont(_ path: String) -> Bool {
    let id = nvgCreateFont(surface.nvg, path, path)
    if id > -1 {
        fontIds[path] = id
    }
    print("Loaded font from", path, id)
    return id > -1
  }

  override public func deactivate() {
    nvgEndFrame(surface.nvg)
  }
}