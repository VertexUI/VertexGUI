import GfxMath

extension Experimental {
  public class Container: ComposedWidget, ExperimentalStylableWidget {
    private let childBuilder: () -> Widget

    private var padding: Insets {
      stylePropertyValue(StyleKeys.padding, as: Insets.self) ?? Insets(all: 0)
    }

    private init(contentBuilder: () -> ChildBuilder.Result) {
        let content = contentBuilder()
        self.childBuilder = content.child
        super.init()
        self.experimentalProvidedStyles.append(contentsOf: content.experimentalStyles)
    }

    public convenience init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> [Experimental.StyleProperty] = { _ in [] },
      @ChildBuilder content contentBuilder: @escaping () -> ChildBuilder.Result) {
        self.init(contentBuilder: contentBuilder)
        if let classes = classes {
          self.classes = classes
        }
        self.experimentalDirectStyleProperties.append(contentsOf: stylePropertiesBuilder(StyleKeys.self))
    }

    public convenience init(
      configure: (Experimental.Container) -> (),
      @ChildBuilder content contentBuilder: @escaping () -> ChildBuilder.Result) {
        self.init(contentBuilder: contentBuilder)
        configure(self)
    }

    override public func performBuild() {
      let builtChild = childBuilder()
      rootChild = Background() { [unowned self] in
        Experimental.Background(configure: {
          $0.with(styleProperties: {
            ($0.fill, stylePropertyValue(StyleKeys.backgroundFill) ?? Color.transparent)
          })
        }) {
          Experimental.Padding(configure: {
            $0.with(styleProperties: {
              ($0.insets, self.padding)
            })
          }) {
            builtChild
          }
        }
      }
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case padding
      case backgroundFill
    }
  }
}