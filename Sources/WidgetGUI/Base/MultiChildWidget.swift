import VisualAppBase
import CustomGraphicsMath

open class MultiChildWidget: Widget {
    open func render(_ renderedChildren: [RenderObject?]) -> RenderObject? {
        return .Container { renderedChildren }
    }
}