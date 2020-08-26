import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

// TODO: maybe rename to BuildableSingleChildWidget and create another SingleChildWidget as Basis for button?... maybe can simply use Widget for this
open class SingleChildWidget: Widget, BoxWidget {

    open lazy var child: Widget = buildChild()
    
    override open func build() {

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

    open func withChildInvalidation(block: () -> ()) {

        block()

        invalidateChild()
    }

    public func getBoxConfig() -> BoxConfig {

        return (child as! BoxWidget).getBoxConfig()
    }

    override open func performLayout() {
        
        child.constraints = constraints // legacy

        child.bounds.size = bounds.size

        child.layout()
    }    

    override open func renderContent() -> RenderObject? {

        return child.render()
    }
}
