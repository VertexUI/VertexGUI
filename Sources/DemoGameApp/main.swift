import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import CustomGraphicsMath
import Foundation

public class DemoGameApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    let controllableBlob: Blob
    
    public init() {
        let gameState = GameState()
        controllableBlob = Blob(position: DVec2(300, 300), timestamp: Date.timeIntervalSinceReferenceDate)
        gameState.blobs.append(controllableBlob)

        let guiRoot = Root(rootWidget: GameView(state: gameState))

        super.init(system: try! SDL2OpenGL3NanoVGSystem())
        
        let window = newWindow(guiRoot: guiRoot, background: Color(20, 20, 40, 255))
        _ = system.onFrame { [unowned self] deltaTime in
            let step = Double(deltaTime) * (200 / 1000)
            if system.keyStates[.ArrowTop] {
                controllableBlob.position += DVec2(0, step)
            }
            if system.keyStates[.ArrowDown] {
                controllableBlob.position -= DVec2(0, step)
            }
            if system.keyStates[.ArrowRight] {
                controllableBlob.position += DVec2(step, 0)
            }
            if system.keyStates[.ArrowLeft] {
                controllableBlob.position -= DVec2(step, 0)
            }
        }
    }
    
    override open func createRenderer(for window: Window) -> Renderer {
        return SDL2OpenGL3NanoVGRenderer(for: window)
    }
}

let app = DemoGameApp()
try! app.start()