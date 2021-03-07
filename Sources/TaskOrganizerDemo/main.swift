import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import Dispatch
import GfxMath
import Path
import GL
import CSDL2
import ColorizeSwift

// TODO: create a subclass of App, DesktopApp which supports windows/screens which can support different resolutions --> renderContexts --> different text boundsSize
open class TodoApp: WidgetsApp {    
    let guiRoot: WidgetGUI.Root
    let experimentalStore: ExperimentalTodoStore = ExperimentalTodoStore()

    public init() {
        guiRoot = WidgetGUI.Root(rootWidget: Container().withContent {
            TodoAppView().experimentalWith(styleProperties: {
                (\.$grow, 1)
                (\.$alignSelf, .stretch)
            })
        }.provide(dependencies: experimentalStore))
        guiRoot.renderObjectSystemEnabled = false
        super.init(baseApp: SDL2OpenGL3NanoVGVisualApp())
    }

    override open func setup() {
        let window = createWindow(guiRoot: guiRoot, options: Window.Options(), immediate: true)
        #if DEBUG
        //openDevTools(for: window)
        #endif
    }
}

let app = TodoApp()

do {
    try app.start()
} catch {
    print("Error while running app", error)
}
