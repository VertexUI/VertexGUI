import ExperimentalReactiveProperties
import GfxMath
import VisualAppBase

extension Experimental {
  public class Border: Widget, ExperimentalStylableWidget {
    private let contentChild: Widget
    @Reference
    private var drawing: Widget

    @ExperimentalReactiveProperties.ObservableProperty
    private var borderColor: Color?

    @ExperimentalReactiveProperties.ObservableProperty
    private var borderWidths: BorderWidths?

    private init(contentBuilder: () -> SingleChildContentBuilder.Result) {
      let content = contentBuilder()
      self.contentChild = content.child()
      super.init()
      self.experimentalProvidedStyles.append(contentsOf: content.experimentalStyles)

      self._borderColor = stylePropertiesResolver[reactive: StyleKeys.borderColor]
      _ = self.$borderColor.onChanged { [unowned self] _ in
        invalidateRenderState()
      }

      self._borderWidths = stylePropertiesResolver[reactive: StyleKeys.borderWidths]
      _ = self.$borderWidths.onChanged { [unowned self] _ in
        invalidateRenderState()
      }
    }

    public convenience init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type)
        -> Experimental.StyleProperties = { _ in [] },
      @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder
        .Result
    ) {
      self.init(contentBuilder: contentBuilder)
      if let classes = classes {
        self.classes = classes
      }
      self.with(stylePropertiesBuilder(StyleKeys.self))
    }

    override public func performBuild() {
      children = [
        contentChild,
        Experimental.Drawing(draw: self.drawBorder).connect(ref: $drawing),
      ]
    }

    override public func getContentBoxConfig() -> BoxConfig {
      contentChild.boxConfig
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      contentChild.layout(constraints: constraints)
      drawing.layout(constraints: BoxConstraints(size: contentChild.size))
      return constraints.constrain(contentChild.size)
    }

    private func drawBorder(_ drawingContext: DrawingContext) {
      if let borderWidths = borderWidths {
        let strokeColor = borderColor ?? .transparent

        if borderWidths.top > 0 {
          drawingContext.drawLine(
            from: DVec2(0, borderWidths.top / 2),
            to: DVec2(bounds.size.width, borderWidths.top / 2),
            paint: Paint(strokeWidth: borderWidths.top, strokeColor: strokeColor))
        }

        if borderWidths.right > 0 {
          drawingContext.drawLine(
            from: DVec2(bounds.width - borderWidths.right / 2, 0),
            to: DVec2(bounds.width - borderWidths.right / 2, bounds.height),
            paint: Paint(strokeWidth: borderWidths.right, strokeColor: strokeColor))
        }

        if borderWidths.bottom > 0 {
          drawingContext.drawLine(
            from: DVec2(0, bounds.height - borderWidths.bottom / 2),
            to: DVec2(bounds.width, bounds.height - borderWidths.bottom / 2),
            paint: Paint(strokeWidth: borderWidths.bottom, strokeColor: strokeColor))
        }

        if borderWidths.left > 0 {
          drawingContext.drawLine(
            from: DVec2(borderWidths.left / 2, 0), to: DVec2(borderWidths.left / 2, bounds.height),
            paint: Paint(strokeWidth: borderWidths.left, strokeColor: strokeColor))
        }
      }
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case borderColor
      case borderWidths
    }

    public typealias BorderWidths = Insets
  }
}
