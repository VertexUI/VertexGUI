import GfxMath
import Drawing

public class BarChart: LeafWidget {
  public typealias Data = [(label: String, value: Double)]

  @ImmutableBinding
  private var data: Data

  private var drawingData = DrawingData()

  public init(_ data: ImmutableBinding<Data>) {
    self._data = data
    super.init()
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    // TODO: maybe do calculate some preferred size, or even some min size
    constraints.constrain(.zero)
  }

  override public func draw(_ drawingContext: DrawingContext) {
    if data.count == 0 {
      return
    }

    let valueSortedData = data.sorted { $0.value < $1.value }
    let minValue = valueSortedData[0].value 
    let maxValue = valueSortedData.last!.value

    drawingData.minValue = minValue
    drawingData.maxValue = maxValue

    makeYTicks(drawingContext)

    drawingData.barAreaWidth = layoutedSize.width - drawingData.widestYTickWidth

    let datumWidth = drawingData.barAreaWidth / Double(data.count)

    for (index, datum) in data.enumerated() {
      let datumHeight = datum.value / maxValue * layoutedSize.height
      let x0 = Double(index) * datumWidth
      let x1 = Double(x0) + datumWidth
      let y0 = 0.0
      let y1 = datumHeight
      drawingContext.drawRect(rect: DRect(min: DVec2(x0, y0), max: DVec2(x1, y1)), paint: Paint(color: .green))
    } 

    drawYTicks(drawingContext)
  }

  func makeYTicks(_ drawingContext: DrawingContext) {
    drawingData.yTicks = []
    drawingData.widestYTickWidth = 0

    /*let tickTextSize = drawingContext.measureText(
        text: "012345869.1232094",
        paint: TextPaint(fontConfig: tickFontConfig, color: foreground)
    )

    let tickCount = Int(layoutedSize.height / tickTextSize.height)
    let tickDistance = layoutedSize.height / Double(tickCount)
    let tickStep = (drawingData.maxValue - drawingData.minValue) / Double(tickCount)

    for index in 0..<tickCount {
      let tickValue = drawingData.minValue + tickStep * Double(index)
      let tickLabel = String(tickValue)
      let tickYPosition = tickDistance * Double(index)

      drawingData.yTicks.append((label: tickLabel, yPosition: tickYPosition))

      let size = drawingContext.measureText(text: tickLabel, paint: TextPaint(fontConfig: tickFontConfig, color: foreground))

      if size.width > drawingData.widestYTickWidth {
        drawingData.widestYTickWidth = size.width
      }
    }*/
  }

  func drawYTicks(_ drawingContext: DrawingContext) {
    for tick in drawingData.yTicks {
      /*drawingContext.drawText(
        text: tick.label,
        position: DVec2(drawingData.barAreaWidth, tick.yPosition),
        paint: TextPaint(fontConfig: tickFontConfig, color: foreground))*/
    }
  }

  func drawXTicks(_ drawingContext: DrawingContext) {
    
  }

  struct DrawingData {
    var barAreaWidth: Double = 0
    var minValue: Double = 0
    var maxValue: Double = 0
    var widestYTickWidth: Double = 0
    var yTicks: [(label: String, yPosition: Double)] = []
  }
}