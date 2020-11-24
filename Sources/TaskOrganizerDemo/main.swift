import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import Dispatch
import CustomGraphicsMath
import Path
import GL
import CSDL2
import ColorizeSwift

// TODO: create a subclass of App, DesktopApp which supports windows/screens which can support different resolutions --> renderContexts --> different text boundsSize
open class TodoApp: WidgetsApp {    
    open var guiRoot: WidgetGUI.Root
    private var todoStore = TodoStore()

    public init() {
        guiRoot = WidgetGUI.Root(
            rootWidget: DependencyProvider(provide: [
                Dependency(todoStore)
            ]) {
                TodoAppView().with { $0.debugLayout = false }
            })
        super.init(baseApp: SDL2OpenGL3NanoVGVisualApp())
    }

    override open func start() throws {
        let window = createWindow(guiRoot: guiRoot, options: Window.Options(), immediate: true)
        #if DEBUG
        openDevTools(for: window)
        #endif
        try super.start()
    }
}

let app = TodoApp()

do {
    try app.start()
} catch {
    print("Error while running app", error)
}
