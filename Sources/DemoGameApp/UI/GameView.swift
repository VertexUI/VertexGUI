import Foundation
import VisualAppBase
import WidgetGUI
import CustomGraphicsMath
import Dispatch

public class GameView: Widget, GUIMouseEventConsumer {
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

    public func consume(_ event: GUIMouseEvent) {
        if let event = event as? GUIMouseMoveEvent {
            print("GAME VIEW HAVE MOUSE MOVE", event)
            let localPosition = event.position - globalBounds.min

            let center = bounds.center

            let distance = localPosition - center
            
            let accelerationDirection = distance.normalized() * DVec2(1, -1) // multiply to convert between coordinate systems
            
            let referenceLength = (bounds.size.width > bounds.size.height ?
                bounds.size.width : bounds.size.height) / 4

            let speedLimit = min(1, distance.length / referenceLength)

            // TODO: maybe call on Player directly
            player.stateManager.perform(action: .Motion(accelerationDirection: accelerationDirection, speedLimit: speedLimit))
        }
    }
}