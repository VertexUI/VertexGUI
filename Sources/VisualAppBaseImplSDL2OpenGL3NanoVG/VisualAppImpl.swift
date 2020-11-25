import VisualAppBase

open class SDL2OpenGL3NanoVGVisualApp: VisualApp {
  public init(immediate: Bool = false) {
    super.init(system: try! SDL2OpenGL3NanoVGSystem.getInstance(), immediate: immediate)
  }

  override open func createRawWindow(options: Window.Options) -> Window {
    try! SDL2OpenGL3NanoVGWindow(options: options)
  }

  override open func createRenderer(for window: Window) -> Renderer {
    SDL2OpenGL3NanoVGRenderer(for: window as! SDL2OpenGL3NanoVGWindow)
  }

  override open func createTreeSliceRenderer(context: ApplicationContext) -> RenderObjectTreeSliceRenderer {
    SDL2OpenGL3NanoVGRenderObjectTreeSliceRenderer(context: context)
  }
}