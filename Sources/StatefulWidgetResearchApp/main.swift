import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import Dispatch
import CustomGraphicsMath
import Path
import GL
import CSDL2

// TODO: create a subclass of App, DesktopApp which supports windows/screens which can support different resolutions --> renderContexts --> different text boundsSize
open class StatefulWidgetsResearchApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    open var guiRoot: WidgetGUI.Root

    public init() {
        let page = StatefulView()
        guiRoot = WidgetGUI.Root(
            rootWidget: page)

        super.init(system: try! System())

        newWindow(guiRoot: guiRoot, background: .Grey)
    }

    override open func createRenderer(for window: Window) -> Renderer {
        return SDL2OpenGL3NanoVGRenderer(for: window)
    }
}

let app = StatefulWidgetsResearchApp()

do {
    try app.start()
} catch {
    print("Error while running app", error)
}