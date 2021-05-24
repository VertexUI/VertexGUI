import VisualAppBase
import GfxMath
import SkiaKit
import CXShim
import Drawing

public class Text: LeafWidget {
  /*private var fontConfig: FontConfig {
    FontConfig(
      family: fontFamily,
      size: fontSize,
      weight: fontWeight,
      style: fontStyle
    )
  }*/

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
    let nonEmptyTransformedText = transformedText.isEmpty ? " " : transformedText

    var textSizeMeasurement = measureText(nonEmptyTransformedText)//context.measureText(text: boundedText, paint: TextPaint(fontConfig: fontConfig, color: foreground))

    // keep height, so that there is no layout position update when text changes to non empty
    if transformedText.isEmpty {
      textSizeMeasurement.width = 0
    }

    // fix glitches that create unnecessary line breaks, probably because floating point inprecisions
    // might need to be larger
    textSizeMeasurement.width += 4

    return max(constraints.minSize, textSizeMeasurement)
  }

  override public func draw(_ drawingContext: DrawingContext, canvas: Canvas) {
    if self.transformedText.count > 0 {
      let font = createFont()
      let paint = createPaint()
      canvas.draw(text: self.transformedText, x: 0, y: 0, font: font, paint: paint)
    }
    //drawingContext.drawText(text: self.transformedText, position: .zero, paint: TextPaint(fontConfig: fontConfig, color: foreground))
  }

  public func measureText(_ text: String) -> DSize2 {
    //context.measureText(text: text, paint: TextPaint(fontConfig: fontConfig, color: foreground))
    let font = createFont()
    let paint = createPaint()
    return font.measureText(self.transformedText, paint: paint).size
  }

  private func createPaint() -> SkiaKit.Paint {
    Paint(fill: foreground)
  }

  private func createFont() -> SkiaKit.Font {
    let font = Font()
    font.size = Float(fontSize)
    return font
  }
}