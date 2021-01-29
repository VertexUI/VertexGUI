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

    public convenience init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result) {
        self.init(contentBuilder: contentBuilder)
        if let classes = classes {
          self.classes = classes
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))
    }

    override open func getBoxConfig() -> BoxConfig {
      rootChild!.getBoxConfig()
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {
      rootChild?.layout(constraints: constraints)
      return constraints.constrain(rootChild?.size ?? .zero)
    }

    override open func renderContent() -> RenderObject? {
      return rootChild?.render(reason: .renderContentOfParent(self))
    }
  }
}