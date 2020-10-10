import Dispatch
import Foundation

open class VisualApp<S: System, W: Window>: App<S, W> {

    private var renderObjectTreeRenderer: RenderObjectTreeRenderer

    private var renderObjectTree: RenderObjectTree

    public init(system: System, immediate: Bool = false) {

        self.renderObjectTree = RenderObjectTree()

        if immediate {
            
            self.renderObjectTreeRenderer = ImmediateRenderObjectTreeRenderer(self.renderObjectTree)

        } else {

            self.renderObjectTreeRenderer = OptimizingRenderObjectTreeRenderer(self.renderObjectTree)
        }

        super.init(system: system)

        _ = system.onTick(onTick)

        _ = system.onFrame(onFrame)
    }

    open func onTick(_ tick: Tick) {

    }

    open func onFrame(_ deltaTime: Int) {

    }
}
