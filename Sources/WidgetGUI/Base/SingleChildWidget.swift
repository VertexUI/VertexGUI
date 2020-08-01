import VisualAppBase
import CustomGraphicsMath

// TODO: maybe rename to BuildableSingleChildWidget and create another SingleChildWidget as Basis for button?... maybe can simply use Widget for this
open class SingleChildWidget: Widget {
    open lazy var child: Widget = buildChild()
    
    override open func build() {
        //child = buildChild()
        children = [child]
    }

    open func buildChild() -> Widget {
        fatalError("buildChild() not implemented.")
    }

    open func invalidateChild() {
        if !mounted || destroyed {
            return
        }

        child = buildChild()
        replaceChildren(with: [child])
        
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
