import Foundation
import VisualAppBase
import WidgetGUI
import CustomGraphicsMath
import Dispatch

public class GameView: Widget {
    private let player: Player
    private let gameRenderer: GameRenderer
    private var previousRenderTimestamp: Double = Date.timeIntervalSinceReferenceDate
    
    public init(player: Player) {
        self.player = player
        self.gameRenderer = GameRenderer(state: player.state)
    }

    override open func performLayout() {
        bounds.size = constraints!.maxSize
    }

    override open func renderContent() -> RenderObject? {
        return RenderObject.Custom(id: id) { [unowned self] renderer in

            let currentRenderTimestamp = Date.timeIntervalSinceReferenceDate

            let deltaTime = currentRenderTimestamp - previousRenderTimestamp

            previousRenderTimestamp = currentRenderTimestamp

            player.stateManager.retrieveUpdates()

            // TODO: retrieve delta time from RenderObject render function
            try gameRenderer.render(renderArea: globalBounds, window: context!.window, renderer: renderer, deltaTime: deltaTime)
        }
    }
}