import Foundation
import VisualAppBase
import WidgetGUI
import CustomGraphicsMath
import Dispatch

public class GameView: Widget {
    public var perspective: GamePerspective
    private let gameRenderer: GameRenderer
    private var previousRenderTimestamp: Double = Date.timeIntervalSinceReferenceDate
    
    public init(state: GameState, perspective: GamePerspective) {
        self.perspective = perspective
        self.gameRenderer = GameRenderer(state: state)
    }

    override open func performLayout() {
        bounds.size = constraints!.maxSize
    }

    override open func renderContent() -> RenderObject? {
        return RenderObject.Custom(id: id) { [unowned self] renderer in
            let currentRenderTimestamp = Date.timeIntervalSinceReferenceDate
            let deltaTime = currentRenderTimestamp - previousRenderTimestamp
            previousRenderTimestamp = currentRenderTimestamp
            // TODO: retrieve delta time from RenderObject render function
            gameRenderer.updateRenderState(from: perspective, deltaTime: deltaTime)
            try gameRenderer.render(from: perspective, in: globalBounds, with: renderer)
        }
    }
}