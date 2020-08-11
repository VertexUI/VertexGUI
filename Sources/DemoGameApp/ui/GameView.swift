import Foundation
import VisualAppBase
import WidgetGUI
import CustomGraphicsMath
import Dispatch

public class GameView: Widget {
    public var perspective: GamePerspective
    private let gameRenderer: GameRenderer
    private var previousRenderTimestamp: Double = Date.timeIntervalSinceReferenceDate
    private var synchronize: (_ block: () -> ()) -> ()
    
    public init(state: GameState, perspective: GamePerspective, synchronize: @escaping (_ block: () -> ()) -> ()) {
        self.perspective = perspective
        self.gameRenderer = GameRenderer(state: state)
        self.synchronize = synchronize
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
            synchronize {
                gameRenderer.updateRenderState(from: perspective, deltaTime: deltaTime)
            }
            try gameRenderer.render(from: perspective, renderArea: globalBounds, window: context!.window, renderer: renderer)
        }
    }
}