import Foundation
import VisualAppBase
import WidgetGUI
import GfxMath
import Dispatch

public class GameView: Widget, GUIMouseEventConsumer {
    private let player: Player
    private let gameRenderer: GameRenderer
    private var previousRenderTimestamp: Double = Date.timeIntervalSinceReferenceDate
    
    public init(player: Player) {
        self.player = player
        self.gameRenderer = GameRenderer(state: player.state)
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {
        
        return constraints.constrain(DSize2(800, 800))
    }

    override open func renderContent() -> RenderObject? {
        return RenderObject.Custom(id: id) { [unowned self] renderer in

            let currentRenderTimestamp = Date.timeIntervalSinceReferenceDate

            let deltaTime = currentRenderTimestamp - previousRenderTimestamp

            previousRenderTimestamp = currentRenderTimestamp

            // TODO: maybe do this outside of here, maybe update all players befofore onFrame
            player.stateManager.retrieveUpdates()

            // TODO: retrieve delta time from RenderObject render function
            gameRenderer.render(renderArea: globalBounds, window: context!.window, renderer: renderer, deltaTime: deltaTime)
        }
    }

    public func consume(_ event: GUIMouseEvent) {
        if let event = event as? GUIMouseMoveEvent {

            let localPosition = event.position - globalBounds.min

            let center = bounds.center

            let distance = localPosition - center
            
            let accelerationDirection = distance.normalized() * DVec2(1, -1) // multiply to convert between coordinate systems
            
            let referenceLength = (bounds.size.width > bounds.size.height ?
                bounds.size.width : bounds.size.height) / 4

            let speedLimit = min(1, distance.length / referenceLength)

            // TODO: maybe call on Player directly --> maybe PlayerManager has player, player does not know manager but publishes events
            player.stateManager.perform(action: .Motion(accelerationDirection: accelerationDirection, speedLimit: speedLimit))
        }
    }
}