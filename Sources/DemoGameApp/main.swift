import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import CustomGraphicsMath
import Foundation

public class DemoGameApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    private let gameProcessor: GameProcessor
    private let gameState: GameState

    private var gameRuleset = Observable(GameRuleset())

    lazy private var player: Player = createPlayer()

    lazy private var guiRoot: Root = buildGuiRoot()
    lazy private var gameView: GameView = buildGameView()

    private let updateQueue = DispatchQueue(label: "swift-cross-platform-demo.game", qos: .background)

    public init() {
        gameState = GameState()

        gameProcessor = GameProcessor(state: gameState, ruleset: gameRuleset.value)

        super.init(system: try! SDL2OpenGL3NanoVGSystem())

        let window = createWindow(guiRoot: guiRoot, background: Color(20, 20, 40, 255))

        _ = gameRuleset.onChanged { [unowned self] _ in
            updateQueue.async {
                gameProcessor.updateRuleset(gameRuleset.value)
            }
        }
    }

    private func createPlayer() -> Player {
        Player(
            stateManager: LocalPlayerStateManager(
                gameProcessor: gameProcessor, 
                synchronize: { [unowned self] block in
                    updateQueue.sync {
                        block()
                    }
                }))
    }

    private func buildGameView() -> GameView {
        GameView(player: player)
    }

    private func buildGuiRoot() -> Root {
        Root(rootWidget: DependencyProvider(provide: [
            Dependency(gameRuleset)
        ]) {
            Space(DSize2(20, 20))
            /*ThemeProvider(DefaultTheme(mode: .Dark, primaryColor: .Blue)) { [unowned self] in
                Column {
                    ComputedSize {
                        Background(fill: Color(40, 40, 80, 255), shape: .Rectangle) {
                            Padding(all: 32) {
                                Text("An awesome game.", fontSize: 24, fontWeight: .Bold, color: .White)
                            }
                        }
                    } calculate: {
                        BoxConstraints(minSize: DSize2($0.maxSize.width, $0.minSize.height), maxSize: $0.maxSize)
                    }

                    Row {
                        ComputedSize(width: .Percent(80)) {
                            MouseArea {
                                gameView
                                // TODO: change this when forward scan is there
                            } onClick: { _ in } onMouseMove: { [unowned self] in handleGameMouseMove($0) }
                        }

                        // TODO: fix issue with constraints in Row and relayouting...
                        ComputedSize(width: .Percent(20)) {
                            
                            Column {

                                GameControlView()
                            }
                        }
                    }
                }
            }*/
        })
    }

    private func handleGameMouseMove(_ event: GUIMouseEvent) {
       // let localPosition = event.position - gameView.bounds.min
        
    }

    private func loopUpdate() {
        var lastFrameTimestamp = Date.timeIntervalSinceReferenceDate
        updateQueue.asyncAfter(
            deadline: DispatchTime.now() + .milliseconds(10)) { [unowned self] in
                let currentFrameTimestamp = Date.timeIntervalSinceReferenceDate
                let deltaTime = currentFrameTimestamp - lastFrameTimestamp
                lastFrameTimestamp = currentFrameTimestamp
                gameProcessor.update(deltaTime: deltaTime)
                loopUpdate()
        }
    }

    /*private func updateDrawableState(deltaTime: Double) {
        let events = updateQueue.sync {
            return gameProcessor.popEventQueue()
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