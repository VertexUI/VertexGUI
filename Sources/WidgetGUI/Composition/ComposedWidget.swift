import VisualAppBase
import GfxMath

open class ComposedWidget: Widget {
  open var rootChild: Widget?
  override open var contentChildren: [Widget] {
    get {
      rootChild == nil ? [] : [rootChild!]
    }
    set {
      
    }
  }

  override public init() {}

  public init(contentBuilder: () -> SingleChildContentBuilder.Result) {
    let content = contentBuilder()
    self.rootChild = content.child()
    super.init()
    self.providedStyles.append(contentsOf: content.styles)
    self.createsStyleScope = true
  }

  public convenience init(
    classes: [String]? = nil,
    @StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> StyleProperties = { _ in [] },
    @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result) {
      self.init(contentBuilder: contentBuilder)
      if let classes = classes {
        self.classes = classes
      }
      self.directStyleProperties.append(stylePropertiesBuilder(StyleKeys.self))
  }

  override open func performLayout(constraints: BoxConstraints) -> DSize2 {
    rootChild?.layout(constraints: constraints)
    return rootChild?.layoutedSize ?? .zero
  }
}