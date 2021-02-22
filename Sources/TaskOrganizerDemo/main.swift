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
    let todoStore: TodoStore
    let searchStore: SearchStore
    let navigationStore: NavigationStore

    public init() {
        todoStore = TodoStore()
        searchStore = SearchStore(todoStore: todoStore)
        navigationStore = NavigationStore()
        guiRoot = WidgetGUI.Root(rootWidget: Container().with(styleProperties: { _ in
            (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.stretch)
        }).withContent {
            TodoAppView().with(styleProperties: { _ in
                (SimpleLinearLayout.ChildKeys.grow, 1.0)
            })
        }.provide(dependencies: todoStore, searchStore, navigationStore))
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
