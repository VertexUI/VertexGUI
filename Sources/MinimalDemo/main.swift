import SwiftGUI

public class MinmalDemoApp: WidgetsApp {
  public init() {
    super.init(baseApp: SDL2OpenGL3NanoVGVisualApp())

    let guiRoot = WidgetGUI.Root(rootWidget: MainView())

    _ = createWindow(guiRoot: guiRoot, options: Window.Options(background: Color(20, 36, 50, 255)), immediate: true)
  }
}

let app = MinmalDemoApp()

do {
  try app.start()
} catch {
  print("Error while running the app", error)
}