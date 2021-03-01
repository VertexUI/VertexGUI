import SwiftGUI

public class DevApp: WidgetsApp {
  @MutableProperty
  var myValue = "my first reactive wow"

  public init() {
    super.init(baseApp: SDL2OpenGL3NanoVGVisualApp())
  }

  override open func setup() {
    let guiRoot = WidgetGUI.Root(rootWidget: Container().withContent {
      MainView().experimentalWith(styleProperties: {
        (\.$alignSelf, .stretch)
        (\.$grow, 1)
      }).withContent {
        $0.TestSlot1 {
          Text("WOW THIS IS A SLOT TEXT")
        }
      }
    }.provide(dependencies: "THIS STRING IS A DEP"))
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