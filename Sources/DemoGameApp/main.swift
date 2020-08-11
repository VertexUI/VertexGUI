import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import CustomGraphicsMath
import Foundation

public class DemoGameApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    private let gameManager: GameManager
    private let gameState: GameState
    private var playerBlobId: UInt 

    private lazy var guiRoot: Root = buildGuiRoot()
    private lazy var gameView: GameView = buildGameView()

    private let updateQueue = DispatchQueue(label: "swift-cross-platform-demo.game", qos: .background)

    public init() {
        gameState = GameState()

        gameManager = GameManager(state: gameState, ruleset: GameRuleset())

        playerBlobId = gameManager.createPlayerBlob()
        
        super.init(system: try! SDL2OpenGL3NanoVGSystem())

        let window = newWindow(guiRoot: guiRoot, background: Color(20, 20, 40, 255))
        _ = window.onMouse { [unowned self] in
            guiRoot.consumeMouseEvent($0)
        }
 
        _ = system.onFrame { [unowned self] deltaTimeMilliseconds in
            let deltaTime = Double(deltaTimeMilliseconds) / 1000
            updateQueue.sync {
                gameView.perspective = gameState.playerBlobs[playerBlobId]!.perspective
            }
        }
    }

    private func buildGameView() -> GameView {
        GameView(
            state: gameState,
            perspective: gameState.playerBlobs[playerBlobId]!.perspective,
            synchronize: { [unowned self] block in
                updateQueue.sync {
                    block()
                }
            })
    }

    private func buildGuiRoot() -> Root {
        Root(rootWidget: Column {
            ComputedSize {
                Background(Color(40, 40, 80, 255)) {
                    Padding(all: 32) {
                        Text("An awesome game.", config: Text.PartialConfig(
                            fontConfig: PartialFontConfig(size: 24, weight: .Bold),
                            color: .White))
                    }
                }
            } calculate: {
                BoxConstraints(minSize: DSize2($0.maxSize.width, $0.minSize.height), maxSize: $0.maxSize)
            }

            Aligner {
                MouseArea(onMouseMove: { [unowned self] in handleGameMouseMove($0) }) {
                    gameView
                }

                Alignable(horizontal: .End) {
                    Padding(all: 32) {
                        PlayerStatsView()
                    }
                }
            }
        })
    }

    private func handleGameMouseMove(_ event: GUIMouseEvent) {
        let localPosition = event.position - gameView.bounds.min
        let center = gameView.bounds.center
        let distance = localPosition - center
        
        let accelerationDirection = distance.normalized() * DVec2(1, -1) // multiply to convert between coordinate systems
        
        let referenceLength = (gameView.bounds.size.width > gameView.bounds.size.height ?
            gameView.bounds.size.width : gameView.bounds.size.height) / 4
        let speedFactor = min(1, distance.length / referenceLength)

        updateQueue.async { [unowned self] in
            gameState.playerBlobs[playerBlobId]!.accelerationDirection = accelerationDirection
            gameState.playerBlobs[playerBlobId]!.speedFactor = speedFactor
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

    /*private func updateDrawableState(deltaTime: Double) {
        let events = updateQueue.sync {
            return gameManager.popEventQueue()
        }
        drawableManager.process(events: events, deltaTime: deltaTime)
        drawableGameState.perspective = playerBlob.perspective
    }*/
    
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