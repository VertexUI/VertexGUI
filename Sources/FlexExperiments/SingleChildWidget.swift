import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

// TODO: maybe rename to BuildableSingleChildWidget and create another SingleChildWidget as Basis for button?... maybe can simply use Widget for this
open class SingleChildWidget: Widget {

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

        invalidateBoxConfig()
        
        // TODO: make sure layout is not performed twice shortly after another
        // it is probably already called by invalidateBoxConfig
        // have a flag to show that layout is up to date already
        layout()

        invalidateRenderState()
    }

    open func withChildInvalidation(block: () -> ()) {

        block()

        invalidateChild()
    }

    override public func getBoxConfig() -> BoxConfig {

        return child.boxConfig
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
