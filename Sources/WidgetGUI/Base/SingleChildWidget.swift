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
        //layoutInvalid = true

        //layout(constraints: previousConstraints!)
        invalidateLayout()

        invalidateRenderState()
    }

    open func withChildInvalidation(block: () -> ()) {

        block()

        invalidateChild()
    }

    override open func getBoxConfig() -> BoxConfig {

        return child.boxConfig
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {

        child.layout(constraints: constraints)

        return constraints.constrain(child.bounds.size)
    }

    override open func renderContent() -> RenderObject? {

        return child.render()
    }
}
