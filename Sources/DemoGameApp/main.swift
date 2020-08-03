import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import CustomGraphicsMath
import Foundation

public class DemoGameApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    private let gameManager: GameManager
    private let controllableBlob: Blob

    private let updateQueue = DispatchQueue(label: "swift-cross-platform-demo.game", qos: .background)

    public init() {
        let gameState = GameState()
        controllableBlob = Blob(position: DVec2(600, 600), mass: 100, timestamp: Date.timeIntervalSinceReferenceDate)
        gameState.blobs.append(controllableBlob)
        gameState.blobs.append(Blob(position: DVec2(100, 600), mass: 40, timestamp: Date.timeIntervalSinceReferenceDate))
        gameState.blobs.append(Blob(position: DVec2(500, 700), mass: 30, timestamp: Date.timeIntervalSinceReferenceDate))
        gameState.blobs.append(Blob(position: DVec2(800, 900), mass: 10, timestamp: Date.timeIntervalSinceReferenceDate))

        gameManager = GameManager(state: gameState)

        let guiRoot = Root(rootWidget: GameView(state: gameState))

        super.init(system: try! SDL2OpenGL3NanoVGSystem())

        let window = newWindow(guiRoot: guiRoot, background: Color(20, 20, 40, 255))
        _ = window.onKey { [unowned self] in
            if $0.repetition {
                return
            }
            //print("UPDATE KEYS")
            updateQueue.async {
                print("UPDATE KEYS")
                controllableBlob.throttles[.Up] = system.keyStates[.ArrowUp]
                controllableBlob.throttles[.Right] = system.keyStates[.ArrowRight]
                controllableBlob.throttles[.Down] = system.keyStates[.ArrowDown]
                controllableBlob.throttles[.Left] = system.keyStates[.ArrowLeft]
            }
        }
    }

    private func loopUpdate() {
        var lastFrameTimestamp = Date.timeIntervalSinceReferenceDate
        updateQueue.asyncAfter(
            deadline: DispatchTime.now() + .milliseconds(10)) { [unowned self] in
                let currentFrameTimestamp = Date.timeIntervalSinceReferenceDate
                let deltaTime = currentFrameTimestamp - lastFrameTimestamp
                lastFrameTimestamp = currentFrameTimestamp
                gameManager.update(deltaTime: deltaTime)
                loopUpdate()
        }
    }
    
    override open func createRenderer(for window: Window) -> Renderer {
        return SDL2OpenGL3NanoVGRenderer(for: window)
    }

    override open func start() throws {
        loopUpdate()
        try super.start()
    }
}

let app = DemoGameApp()
try! app.start()