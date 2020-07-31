import VisualAppBase
import CustomGraphicsMath

// TODO: maybe rename to BuildableSingleChildWidget and create another SingleChildWidget as Basis for button?... maybe can simply use Widget for this
open class SingleChildWidget: Widget {
    open var child: Widget = Space(size: DSize2(0,0))// = buildChild()
    
    override open func mount(parent: Parent) {
        child = buildChild()
        children = [child]
        super.mount(parent: parent)
    }

    open func buildChild() -> Widget {
        fatalError("buildChild() not implemented.")
    }

    open func invalidateChild() {
        if !mounted || destroyed {
            return
        }

        try! child.destroy()
        
        child = buildChild()
        children = [child]
        mountChild(child)
        
        try! layout()
        invalidateRenderState()
    }

    override open func performLayout() {
        child.constraints = constraints
        try child.layout()
        bounds.size = child.bounds.size
    }    

    override open func renderContent() -> RenderObject? {
        return child.render()
    }
}
