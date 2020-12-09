import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import CSDL2
import Dispatch

func runVisualAppOpenGLTest() {
    DispatchQueue.main.async {
        let system = try! SDL2OpenGL3NanoVGSystem.getInstance()
        let window = try! SDL2OpenGL3NanoVGWindow(options: Window.Options())
        window.clear()
        window.updateContent()
        SDL_Delay(2000)
    }
    dispatchMain()
}