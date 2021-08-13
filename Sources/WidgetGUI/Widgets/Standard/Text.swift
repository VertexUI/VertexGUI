import GfxMath
import SkiaKit
import OpenCombine
import Drawing

public class Text: LeafWidget {
  private var transformedText: String {
    textTransform.apply(to: text)
  }

  @ImmutableBinding
  private var text: String
  private var textSubscription: AnyCancellable?

  public init(_ text: ImmutableBinding<String>) {
    self._text = text
    super.init()
    textSubscription = $text.publisher
    .map { [weak self] _ in self?.transformedText }
    .removeDuplicates().sink { [weak self] _ in
      self?.invalidateLayout()
    }
  }

  public init(_ text: String) {
      self._text = ImmutableBinding(get: { text })
  }
  
  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    let nonEmptyTransformedText = transformedText.isEmpty ? " " : transformedText

    var textSizeMeasurement = measureText(nonEmptyTransformedText).size//context.measureText(text: boundedText, paint: TextPaint(fontConfig: fontConfig, color: foreground))

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
    if transformedText.count > 0 {
      let textDrawBounds = measureText(transformedText)
      let font = createFont()
      let paint = createPaint()
      canvas.draw(text: transformedText, x: Float(textDrawBounds.min.x), y: Float(-textDrawBounds.min.y), font: font, paint: paint)
    }
    //drawingContext.drawText(text: self.transformedText, position: .zero, paint: TextPaint(fontConfig: fontConfig, color: foreground))
  }

  public func measureText(_ text: String) -> DRect {
    //context.measureText(text: text, paint: TextPaint(fontConfig: fontConfig, color: foreground))
    let font = createFont()
    let paint = createPaint()
    return font.measureText(self.transformedText, paint: paint)
  }

  private func createPaint() -> SkiaKit.Paint {
    Paint(fill: foreground)
  }

  private func createFont() -> SkiaKit.Font {
    guard let typeface = Typeface(familyName: fontFamily, weight: fontWeight, width: fontWidth, slant: fontSlant) else {
      fatalError("could not create typeface for text widget")
    }

    let font = Font()
    font.size = Float(fontSize)
    font.typeface = typeface
    return font
  }
}