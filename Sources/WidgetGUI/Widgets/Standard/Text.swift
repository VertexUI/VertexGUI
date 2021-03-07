import VisualAppBase
import GfxMath
import CXShim

public class Text: LeafWidget {
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

  @ImmutableBinding
  private var text: String
  private var expTextSubscription: AnyCancellable?

  public init(_ text: ImmutableBinding<String>) {
    self._text = text
  }

  public init(_ text: String) {
      self._text = ImmutableBinding(get: { text })
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