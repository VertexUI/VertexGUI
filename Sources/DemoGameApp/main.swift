import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import CustomGraphicsMath

public class DemoGameApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    public init() {
        let guiRoot = Root(rootWidget: TestShapeWidget())

        super.init(system: try! SDL2OpenGL3NanoVGSystem())
        
        newWindow(guiRoot: guiRoot, background: Color(20, 20, 40, 255))
    }
    
    override open func createRenderer(for window: Window) -> Renderer {
        return SDL2OpenGL3NanoVGRenderer(for: window)
    }
}

let app = DemoGameApp()
try! app.start()