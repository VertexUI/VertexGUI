import Foundation
import VisualAppBase
import WidgetGUI
import CustomGraphicsMath
import Dispatch

public class GameView: Widget {
    private let gameRenderer: GameRenderer
    
    public init(gameRenderer: GameRenderer) {
        self.gameRenderer = gameRenderer
    }

    override open func performLayout() {
        bounds.size = constraints!.maxSize
    }

    override open func renderContent() -> RenderObject? {
        return RenderObject.Custom(id: id) { [unowned self] renderer in
            try gameRenderer.render(in: globalBounds, with: renderer)
        }
    }
}