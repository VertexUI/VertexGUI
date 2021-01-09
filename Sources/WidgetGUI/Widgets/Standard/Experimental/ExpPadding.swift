import GfxMath

extension Experimental {
  public class Padding: ComposedWidget, ExperimentalStylableWidget {
    private let childBuilder: () -> ChildBuilder.Result

    private var insets: Insets {
      stylePropertyValue(StyleKeys.insets, as: Insets.self) ?? Insets(all: 0)
    }

    public init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> [Experimental.StyleProperty] = { _ in [] },
      @ChildBuilder child childBuilder: @escaping () -> ChildBuilder.Result) {
        self.childBuilder = childBuilder
        super.init()
        if let classes = classes {
          self.classes = classes
        }
        self.experimentalDirectStyleProperties.append(contentsOf: stylePropertiesBuilder(StyleKeys.self))
    }

    public init(
      configure: ((Experimental.Padding) -> ())? = nil,
      @ChildBuilder child childBuilder: @escaping () -> ChildBuilder.Result) {
        self.childBuilder = childBuilder
        super.init()
        if let configure = configure {
          configure(self)
        }
    }

    override public func performBuild() {
      let result = childBuilder()
      rootChild = result.child
      experimentalProvidedStyles.append(contentsOf: result.experimentalStyles)
    }

    override public func getBoxConfig() -> BoxConfig {
      guard let rootChild = self.rootChild else {
        fatalError("rootChild must be available during layout")
      }
      let childConfig = rootChild.boxConfig
      return BoxConfig(
        preferredSize: childConfig.preferredSize + insets.aggregateSize,
        minSize: childConfig.minSize + insets.aggregateSize,
        maxSize: childConfig.maxSize + insets.aggregateSize)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      guard let rootChild = self.rootChild else {
        fatalError("rootChild must be available during layout")
      }
      let childConstraints = BoxConstraints(
        minSize: constraints.minSize - insets.aggregateSize,
        maxSize: constraints.maxSize - insets.aggregateSize
      )
      rootChild.layout(constraints: childConstraints)
      rootChild.position = DPoint2(insets.left, insets.top)
      let childSize = rootChild.size
      let selfSize = childSize + insets.aggregateSize
      return constraints.constrain(selfSize)
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case insets
    }
  }
}