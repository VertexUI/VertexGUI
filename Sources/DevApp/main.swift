import SwiftGUI

public class DevApp: WidgetsApp {
  public init() {
    super.init(baseApp: SDL2OpenGL3NanoVGVisualApp())
  }

  override open func setup() {
    let guiRoot = WidgetGUI.Root(rootWidget: MainView())
    guiRoot.renderObjectSystemEnabled = false 

    let window = createWindow(guiRoot: guiRoot, options: Window.Options(background: Color(20, 36, 50, 255)), immediate: true)
    //openDevTools(for: window)
  }
}

let app = DevApp()

do {
  try app.start()
} catch {
  print("Error while running the app", error)
}