import VertexGUI

let app = try VertexGUI.Application()
try! app.createWindow(widgetRoot: Root(rootWidget: MainView()))

do {
  try app.start()
} catch {
  print("an error occurred while running the app:", error)
}
