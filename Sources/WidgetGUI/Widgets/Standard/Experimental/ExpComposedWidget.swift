import VisualAppBase
import GfxMath

extension Experimental {
  open class ComposedWidget: Widget {
    open var rootChild: Widget?
    override open var children: [Widget] {
      get {
        rootChild == nil ? [] : [rootChild!]
      }
      set {
        
      }
    }

    override open func getBoxConfig() -> BoxConfig {
      rootChild!.getBoxConfig()
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {
      rootChild?.layout(constraints: constraints)
      return constraints.constrain(rootChild?.size ?? .zero)
    }

    override public func renderContent() -> RenderObject? {
      rootChild?.render()
    }
  }
}