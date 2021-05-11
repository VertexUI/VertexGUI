import VertexGUI
import ApplicationBackendSDL2

open class TodoApp: VertexGUI.Application {    
    /*let guiRoot: WidgetGUI.Root
    let store: TodoStore = TodoStore()

    public init() {
        guiRoot = WidgetGUI.Root(rootWidget: Container().withContent {
            TodoAppView().with(styleProperties: {
                (\.$grow, 1)
                (\.$alignSelf, .stretch)
            })
        }.provide(dependencies: store))
        super.init(baseApp: SDL2OpenGL3NanoVGVisualApp())
    }

    override open func setup() {
        let window = createWindow(guiRoot: guiRoot, options: Window.Options(), immediate: true)
        #if DEBUG
        //openDevTools(for: window)
        #endif
    }*/
}

let app = try TodoApp()

try app.createWindow(widgetRoot: Root(rootWidget: Text("WOW")))

do {
    try app.start()
} catch {
    print("Error while running app", error)
}
