import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import CustomGraphicsMath
import Foundation

public class DemoGameApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    private let gameManager: GameManager
    private let gameState: GameState
    private let drawableManager: DrawableGameStateManager
    private let drawableGameState: DrawableGameState
    private let controllableBlob: PlayerBlob

    private let updateQueue = DispatchQueue(label: "swift-cross-platform-demo.game", qos: .background)

    public init() {
        gameState = GameState()
        controllableBlob = PlayerBlob(position: DVec2(600, 600), mass: 100, timestamp: Date.timeIntervalSinceReferenceDate)

        gameManager = GameManager(state: gameState)
        gameManager.add(blob: controllableBlob)
        
        drawableGameState = DrawableGameState()

        drawableManager = DrawableGameStateManager(drawableState: drawableGameState)

        super.init(system: try! SDL2OpenGL3NanoVGSystem())

        let gameRenderer = GameRenderer(getRenderData: { [unowned self] in
            let events = updateQueue.sync {
                return gameManager.popEventQueue()
            }
            drawableManager.process(events: events)
            return (drawableState: drawableGameState, perspective: controllableBlob.perspective)
        })

        let guiRoot = Root(rootWidget: Column {
            ComputedSize {
                Background(background: Color(40, 40, 80, 255)) {
                    Padding(all: 32) {
                        Text("An awesome game.", config: Text.PartialConfig(fontConfig: PartialFontConfig(size: 24, weight: .Bold)))
                    }
                }
            } calculate: {
                BoxConstraints(minSize: DSize2($0.maxSize.width, $0.minSize.height), maxSize: $0.maxSize)
            }

            GameView(gameRenderer: gameRenderer)
        })

        let window = newWindow(guiRoot: guiRoot, background: Color(20, 20, 40, 255))
        _ = window.onKey { [unowned self] in
            if $0.repetition {
                return
            }

            updateQueue.async {
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