import GfxMath
import VisualAppBase
import ExperimentalReactiveProperties

extension Experimental {
  public class BarChart: Widget {
    public typealias Data = [(label: String, value: Double)]

    @ExperimentalReactiveProperties.ObservableProperty
    private var data: Data

    public init<P: ReactiveProperty>(_ dataProperty: P) where P.Value == Data {
      super.init()
      self.$data.bind(dataProperty)
    }

    override public func getBoxConfig() -> BoxConfig {
      BoxConfig(preferredSize: DSize2(400, 400))
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      constraints.constrain(boxConfig.preferredSize)
    }

    override public func renderContent() -> RenderObject? {
      var image = Image(width: max(1, Int(width)), height: max(1, Int(height)), value: 255)

      let datumWidth = Double(image.width) / Double(data.count)
      let maxValue = data.reduce(0) {
        $1.value > $0 ? $1.value : $0
      }
      for (index, datum) in data.enumerated() {
        let datumHeight = datum.value / maxValue * Double(image.height)
        let x0 = Int(Double(index) * datumWidth)
        let x1 = Int(Double(x0) + datumWidth)
        let y0 = Int(Double(image.height) - datumHeight)
        let y1 = image.height
        image.drawRect(x0..<x1, y0..<y1, color: .green)
      } 

      return RenderStyleRenderObject(fill: FixedRenderValue(.Image(image, position: globalBounds.min))) {
        RectangleRenderObject(globalBounds)
      }
    }
  }
}