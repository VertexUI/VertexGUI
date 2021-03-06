import ReactiveProperties
import VisualAppBase
import GfxMath
import CXShim

public class Text: LeafWidget {
  @ObservableProperty
  private var text: String

  private var fontConfig: FontConfig {
    FontConfig(
      family: fontFamily,
      size: fontSize,
      weight: fontWeight,
      style: fontStyle
    )
  }

  private var transformedText: String {
    textTransform.apply(to: text)
  }

  @Experimental.ImmutableBinding
  private var expText: String
  private var expTextSubscription: AnyCancellable?

  public init<P: ReactiveProperty>(
    _ textProperty: P) where P.Value == String {
      self._expText = Experimental.ImmutableBinding<String>(State(wrappedValue: "wow"), get: { $0 })
      super.init()

       self.$text.bind(textProperty)
      _ = onDestroy(self.$text.onChanged { [unowned self] _ in
        invalidateLayout()
      })
  }

  public init(_ text: Experimental.ImmutableBinding<String>) {
    self._expText = text
    super.init()
    let tmpBackingProperty = MutableProperty<String>()
    tmpBackingProperty.value = text.value
    self.$text.bind(tmpBackingProperty)
    expTextSubscription = self._expText.sink(receiveValue: { [unowned self] in
      tmpBackingProperty.value = $0
    })
  }

  public convenience init(_ text: String) {
      self.init(StaticProperty(text))
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