import ReactiveProperties
import VisualAppBase
import GfxMath

public class Text: LeafWidget {
  @ObservableProperty
  private var text: String

  private var transform: TextTransform {
    stylePropertyValue(StyleKeys.textTransform, as: TextTransform.self) ?? TextTransform.none
  }
  private var wrap: Bool {
    stylePropertyValue(StyleKeys.wrapText, as: Bool.self) ?? false
  }
  private var fontConfig: FontConfig {
    FontConfig(
      family: stylePropertyValue(StyleKeys.fontFamily, as: FontFamily.self) ?? defaultFontFamily,
      size: stylePropertyValue(StyleKeys.fontSize, as: Double.self) ?? 12,
      weight: stylePropertyValue(StyleKeys.fontWeight, as: FontWeight.self) ?? .regular,
      style: stylePropertyValue(StyleKeys.fontStyle, as: FontStyle.self) ?? .normal
    )
  }

  private var transformedText: String {
    transform.apply(to: text)
  }

  public init<P: ReactiveProperty>(
    classes: [String]? = nil,
    @StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> StyleProperties = { _ in [] },
    _ textProperty: P) where P.Value == String {
      super.init()

      if let classes = classes {
        self.classes = classes
      }
      self.directStyleProperties.append(stylePropertiesBuilder(StyleKeys.self))

      self.$text.bind(textProperty)
      _ = onDestroy(self.$text.onChanged { [unowned self] _ in
        invalidateLayout()
      })
  }

  public convenience init(
    classes: [String]? = nil,
    @StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> StyleProperties = { _ in [] },
    _ text: String) {
      self.init(classes: classes, styleProperties: stylePropertiesBuilder, StaticProperty(text))
  }
  
  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    let boundedText = transformedText.isEmpty ? " " : transformedText

    var textSizeMeasurement = context.measureText(text: boundedText, paint: TextPaint(fontConfig: fontConfig, color: foreground))
    
    if transformedText.isEmpty {
      textSizeMeasurement.width = 0
    }

    // fix glitches that create unnecessary line breaks, probably because floating point inprecisions
    // might need to be larger
    textSizeMeasurement.width += 4

    return max(constraints.minSize, textSizeMeasurement)
  }

  override public func draw(_ drawingContext: DrawingContext) {
    drawingContext.drawText(text: self.transformedText, position: .zero, paint: TextPaint(fontConfig: fontConfig, color: foreground))
  }

  public func measureText(_ text: String) -> DSize2 {
    context.measureText(text: text, paint: TextPaint(fontConfig: fontConfig, color: foreground))
  }
}