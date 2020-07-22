import VisualAppBase

open class SingleChildWidget: Widget {
    open var child: Widget
    
    public init(child: Widget) {
        self.child = child
        super.init()
        child.parent = self
        // TODO: maybe dangling closure
        _ = child.onRenderStateInvalidated {
            self.invalidateRenderState($0)
        }
        //child.context = context
    }

    open func render(_ renderedChild: RenderObject?) -> RenderObject? {
        return renderedChild 
    }
}