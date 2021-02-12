import ExperimentalReactiveProperties
import GfxMath

extension Experimental {
  public class ConstrainedSizeBox: Experimental.ComposedWidget, ExperimentalStylableWidget {
    @ExperimentalReactiveProperties.ObservableProperty
    private var targetWidth: Double?
    @ExperimentalReactiveProperties.ObservableProperty
    private var targetHeight: Double?

    override public init(contentBuilder: () -> SingleChildContentBuilder.Result) {
      super.init(contentBuilder: contentBuilder)
      _targetWidth = stylePropertyValue(reactive: StyleKeys.width)
      _targetHeight = stylePropertyValue(reactive: StyleKeys.height)
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

    override public func getContentBoxConfig() -> BoxConfig {
      let preferredSize = DSize2(targetWidth ?? rootChild!.boxConfig.preferredSize.width,
        targetHeight ?? rootChild!.boxConfig.preferredSize.height)
      return BoxConfig(preferredSize: preferredSize, minSize: rootChild!.boxConfig.minSize, maxSize: rootChild!.boxConfig.maxSize)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      var childConstraints = constraints
      if let targetWidth = targetWidth {
        childConstraints.minWidth = targetWidth
        childConstraints.maxWidth = targetWidth
      }
      if let targetHeight = targetHeight {
        childConstraints.minHeight = targetHeight
        childConstraints.maxHeight = targetHeight
      }
      rootChild!.layout(constraints: childConstraints)
      return constraints.constrain(rootChild!.size)
    }

    public struct StyleKeys: ExperimentalDefaultStyleKeys {
    }
  }
}