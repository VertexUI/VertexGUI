import VisualAppBase

open class SingleChildWidget: Widget {
    open var child: Widget
    
    public init(child: Widget) {
        self.child = child
        super.init()
        child.parent = self
        //child.context = context
    }

    override open func render() -> RenderObject? {
        return child.render()
    }
}