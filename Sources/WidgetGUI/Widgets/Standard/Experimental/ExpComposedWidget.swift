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

    public init() {}

    public init(contentBuilder: () -> SingleChildContentBuilder.Result) {
      let content = contentBuilder()
      self.rootChild = content.child()
      super.init()
      self.experimentalProvidedStyles.append(contentsOf: content.experimentalStyles)
    }

    override open func getBoxConfig() -> BoxConfig {
      rootChild!.getBoxConfig()
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {
      rootChild?.layout(constraints: constraints)
      return constraints.constrain(rootChild?.size ?? .zero)
    }

    override public func renderContent() -> RenderObject? {
      print("ROOT CHILD RENDER", self, rootChild)
      return rootChild?.render()
    }
  }
}