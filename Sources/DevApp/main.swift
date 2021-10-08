import VertexGUI

let app = try VertexGUI.Application()

try app.createWindow(widgetRoot: WidgetGUI.Root(rootWidget: Container().withContent {
  MainView().with(styleProperties: {
    (\.$alignSelf, .stretch)
    (\.$grow, 1)
    (\.$background, .white)
  })
}))

do {
  try app.start()
} catch {
  print("Error while running the app", error)
}