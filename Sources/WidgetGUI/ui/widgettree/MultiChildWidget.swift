import VisualAppBase
import CustomGraphicsMath

open class MultiChildWidget: Widget {
    open var children: [Widget]
    
    public init(children: [Widget]) {
        self.children = children
        super.init()
        for child in children {
            child.parent = self
            // TODO: maybe dangling closure
            _ = child.onRenderStateInvalidated {
                self.invalidateRenderState($0)
            }
            //child.context = context
        }
    }

    /*override open func render() -> RenderObject? {
        return .Container(children.compactMap { $0.render() })
    }*/

    open func render(_ renderedChildren: [RenderObject?]) -> RenderObject? {
        return .Container(renderedChildren.compactMap {$0 })
    }
}