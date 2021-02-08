import GfxMath
import VisualAppBase

extension Widget {
  public class ScrollBar: Widget, LeafWidget {
    //public var background: Color = Color.black
    public var track: Color = Color.red
    //public var width: Double = 20.0

    /*public var hover = false
    public var active = false*/
    private let orientation: Orientation

    public init(orientation: Orientation) {
      self.orientation = orientation
      super.init()
      self.unaffectedByParentScroll = true
    }

    override public func getContentBoxConfig() -> BoxConfig {
      switch orientation {
        case .horizontal:
          return BoxConfig(preferredSize: DSize2(0, 20))
        case .vertical:
          return BoxConfig(preferredSize: DSize2(20, 0))
      }
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      constraints.constrain(boxConfig.preferredSize)
    }

    public func draw(_ drawingContext: DrawingContext) {
      let color: Color
      switch orientation {
      case .horizontal: color = .blue
      case .vertical: color = .grey
      }
      drawingContext.drawRect(rect: DRect(min: .zero, size: size), paint: Paint(color: color))
    }

    public enum Orientation {
      case horizontal, vertical
    }
  }
}