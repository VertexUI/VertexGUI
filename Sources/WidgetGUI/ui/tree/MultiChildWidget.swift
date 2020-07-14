import VisualAppBase

open class MultiChildWidget: Widget {
    open var children: [Widget]
    
    public init(children: [Widget]) {
        self.children = children
        super.init()
        for child in children {
            child.parent = self
            //child.context = context
        }
    }

    override open func render() -> RenderObject? {
        return .Container(children.compactMap { $0.render() })
    }
}