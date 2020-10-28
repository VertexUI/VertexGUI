import SwiftGUI

public class MinmalDemoApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
  public init() {
    super.init(system: try! System())

    let guiRoot = WidgetGUI.Root(rootWidget: MainView())

    _ = createWindow(guiRoot: guiRoot, background: Color(20, 36, 50, 255), immediate: true)
  }

  override open func createRenderer(for window: Window) -> Renderer {
      return SDL2OpenGL3NanoVGRenderer(for: window)
  }
}

let app = MinmalDemoApp()

do {
  try app.start()
} catch {
  print("Error while running the app", error)
}