import VisualAppBase

open class SDL2OpenGL3NanoVGVisualApp: VisualApp<
SDL2OpenGL3NanoVGSystem,
SDL2OpenGL3NanoVGWindow,
SDL2OpenGL3NanoVGRenderObjectTreeSliceRenderer,
SDL2OpenGL3NanoVGRenderer> {

  public init(immediate: Bool = false) {
    super.init(system: try! System(), immediate: immediate)
  }

  override open func createRenderer(for window: Window) -> Renderer {
    Renderer(for: window)
  }

  override open func createTreeSliceRenderer(context: ApplicationContext) -> TreeSliceRenderer {
    TreeSliceRenderer(context: context)
  }
}