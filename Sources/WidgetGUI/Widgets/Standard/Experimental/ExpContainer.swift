import GfxMath

extension Experimental {
  public class Container: Widget, ExperimentalStylableWidget {
    @FromStyle(key: StyleKeys.layout)
    private var layoutType: Layout.Type = AbsoluteLayout.self
    lazy private var layoutInstance: Layout = layoutType.init(widgets: contentChildren)

    public init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      @MultiChildContentBuilder content contentBuilder: @escaping () -> MultiChildContentBuilder.Result) {
        let content = contentBuilder()
        super.init()

        self.contentChildren = content.childrenBuilder()

        self.experimentalProvidedStyles.append(contentsOf: content.experimentalStyles)
        if let classes = classes {
          self.classes = classes
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))

        _ = $layoutType.onChanged { [unowned self] in
          if ObjectIdentifier($0.old) != ObjectIdentifier($0.new) {
            updateLayoutInstance()
          }
        }
    }

    private func updateLayoutInstance() {
      layoutInstance = layoutType.init(widgets: contentChildren)
    }

    override public func getContentBoxConfig() -> BoxConfig {
      return layoutInstance.getBoxConfig()
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      return layoutInstance.layout(constraints: constraints)
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case layout
    }
  }
}