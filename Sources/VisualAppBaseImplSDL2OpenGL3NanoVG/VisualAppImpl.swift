import VisualAppBase

open class SDL2OpenGL3NanoVGVisualApp: VisualApp {
  public init(immediate: Bool = false) {
    super.init(system: try! SDL2OpenGL3NanoVGSystem.getInstance(), immediate: immediate)
  }

  override open func createRawWindow(options: Window.Options) -> Window {
    try! SDL2OpenGL3NanoVGWindow(options: options)
  }
}