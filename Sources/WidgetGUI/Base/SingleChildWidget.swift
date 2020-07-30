import VisualAppBase

// TODO: maybe rename to BuildableSingleChildWidget and create another SingleChildWidget as Basis for button?... maybe can simply use Widget for this
open class SingleChildWidget: Widget {
    open lazy var child: Widget = buildChild()
    
    override open func mount(parent: Parent) {
        children = [child]
        super.mount(parent: parent)
    }

    open func buildChild() -> Widget {
        fatalError("buildChild() not implemented.")
    }

    open func invalidateChild() {
        if destroyed {
            return
        }

        try! child.initiateDestruction()
        
        var child = buildChild()
        child.parent = self
        _ = child.onRenderStateInvalidated {
            self.invalidateRenderState($0)
        }
        self.child = child
        children = [child]
        try! layout()
        invalidateRenderState()
    }

    override open func layout() {
        child.constraints = constraints
        try child.layout()
        bounds.size = child.bounds.size
    }    

    override open func renderContent() -> RenderObject? {
        return child.render()
    }
}