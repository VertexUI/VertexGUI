import GfxMath

extension Experimental {
  public class Container: ComposedWidget, ExperimentalStylableWidget {
    private let childBuilder: SingleChildContentBuilder.ChildBuilder

    @FromStyle(key: StyleKeys.layout)
    private var layoutType: Layout.Type = AbsoluteLayout.self
    lazy private var layoutInstance: Layout = layoutType.init(widgets: contentChildren)

    override private init(contentBuilder: () -> SingleChildContentBuilder.Result) {
        let content = contentBuilder()
        self.childBuilder = content.child
        super.init()
        self.experimentalProvidedStyles.append(contentsOf: content.experimentalStyles)
        _ = $layoutType.onChanged { [unowned self] in
          if ObjectIdentifier($0.old) != ObjectIdentifier($0.new) {
            updateLayoutInstance()
          }
        }
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

    public convenience init(
      configure: (Experimental.Container) -> (),
      @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result) {
        self.init(contentBuilder: contentBuilder)
        configure(self)
    }

    private func updateLayoutInstance() {
      layoutInstance = layoutType.init(widgets: contentChildren)
    }

    override public func performBuild() {
      rootChild = childBuilder()
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case layout
    }
  }
}