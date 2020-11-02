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
open class TodoApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {    
    open var guiRoot: WidgetGUI.Root
    private var todoStore = TodoStore()

    public init() {
        guiRoot = WidgetGUI.Root(
            rootWidget: DependencyProvider(provide: [
                Dependency(todoStore)
            ]) {
                TodoAppView().with { $0.debugLayout = false }
            })
        super.init(system: try! System())
    }

    override open func createRenderer(for window: Window) -> Renderer {
        return SDL2OpenGL3NanoVGRenderer(for: window)
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
