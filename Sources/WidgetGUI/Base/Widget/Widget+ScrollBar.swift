import GfxMath
import VisualAppBase
import ReactiveProperties

extension Widget {
  public class ScrollBar: Widget, LeafWidget {
    public var track: Color = Color.red
    private let orientation: Orientation

    @MutableProperty
    public var scrollProgress = 0.0
    public var maxScrollProgress = 0.0

    var trackLength: Double {
      let trackLengthBase: Double
      switch orientation {
      case .horizontal: trackLengthBase = width
      case .vertical: trackLengthBase = height
      }
      return trackLengthBase / (1 + maxScrollProgress)
    }

    private var trackingMouse = false
    private var trackingStartProgress = 0.0
    private var trackingStartPosition: DPoint2 = .zero

    public init(orientation: Orientation) {
      self.orientation = orientation
      super.init()
      self.unaffectedByParentScroll = true

      _ = onMouseDown(handleMouseDown)
      _ = onMouseUp(handleMouseUp)

      _ = onMounted { [unowned self] in
        _ = onDestroy(rootParent.onMouseMove.addHandler(handleMouseMove))
      }
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

    func handleMouseDown(_ event: GUIMouseButtonDownEvent) {
      if event.button == .Left {
        trackingMouse = true
        trackingStartProgress = scrollProgress
        trackingStartPosition = event.globalPosition
      }
    }

    func handleMouseMove(_ event: GUIMouseMoveEvent) {
      if trackingMouse {
        let relevantMove: Double
        switch orientation {
        case .horizontal: relevantMove = event.globalPosition.x - trackingStartPosition.x
        case .vertical: relevantMove = event.globalPosition.y - trackingStartPosition.y
        }
        scrollProgress = max(min(trackingStartProgress + relevantMove / trackLength, maxScrollProgress), 0)
      }
    }

    func handleMouseUp(_ event: GUIMouseButtonUpEvent) {
      if event.button == .Left {
        trackingMouse = false
      }
    }

    public func draw(_ drawingContext: DrawingContext) {
      let color: Color
      switch orientation {
      case .horizontal: color = .blue
      case .vertical: color = .grey
      }
      drawingContext.drawRect(rect: DRect(min: .zero, size: size), paint: Paint(color: color))

      let trackOffset = trackLength * scrollProgress

      let trackRect: DRect
      switch orientation {
      case .horizontal:
        trackRect = DRect(min: DVec2(trackOffset, 0), size: DSize2(trackLength, height))
      case .vertical:
        trackRect = DRect(min: DVec2(0, trackOffset), size: DSize2(width, trackLength))
      }
      drawingContext.drawRect(rect: trackRect, paint: Paint(color: track))
    }

    public enum Orientation {
      case horizontal, vertical
    }
  }
}