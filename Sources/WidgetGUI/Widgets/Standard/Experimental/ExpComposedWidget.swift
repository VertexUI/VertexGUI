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
      self.createsStyleScope = true
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

    override open func performBuild() {
      contentChildren = rootChild != nil ? [rootChild!] : []
    }

    override open func getContentBoxConfig() -> BoxConfig {
      rootChild!.getBoxConfig()
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {
      rootChild?.layout(constraints: constraints)
      return rootChild?.size ?? .zero
    }
  }
}