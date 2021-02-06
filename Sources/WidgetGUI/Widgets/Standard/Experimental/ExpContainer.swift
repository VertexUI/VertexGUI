import GfxMath

extension Experimental {
  public class Container: ComposedWidget, ExperimentalStylableWidget {
    private let childBuilder: SingleChildContentBuilder.ChildBuilder

    override private init(contentBuilder: () -> SingleChildContentBuilder.Result) {
        let content = contentBuilder()
        self.childBuilder = content.child
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

    public convenience init(
      configure: (Experimental.Container) -> (),
      @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result) {
        self.init(contentBuilder: contentBuilder)
        configure(self)
    }

    override public func performBuild() {
      let builtChild = childBuilder()
      rootChild = Experimental.Border(styleProperties: {
        ($0.borderWidths, stylePropertyValue(reactive: StyleKeys.borderWidths))
        ($0.borderColor, stylePropertyValue(reactive: StyleKeys.borderColor))
      }) { [unowned self] in
        Experimental.Background(styleProperties: {
          ($0.fill, stylePropertyValue(reactive: StyleKeys.backgroundFill))
        }) { 
          Experimental.ConstrainedSizeBox(styleProperties: {
            ($0.width, stylePropertyValue(reactive: StyleKeys.width))
            ($0.height, stylePropertyValue(reactive: StyleKeys.height))
          }) {
            builtChild
          }
        }
      }
    }

    public struct StyleKeys: ExperimentalDefaultStyleKeys, ExperimentalContainerStyleKeys {}
  }
}

public protocol ExperimentalContainerStyleKeys {}
public extension ExperimentalContainerStyleKeys {
  static var width: String {
    "width"
  }
  static var height: String {
    "height"
  }
  static var backgroundFill: String {
    "backgroundFill"
  }
  static var borderWidths: String {
    "borderWidths"
  }
  static var borderColor: String {
    "borderColor"
  }
}