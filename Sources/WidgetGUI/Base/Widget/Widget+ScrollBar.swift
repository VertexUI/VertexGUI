import GfxMath
import VisualAppBase

extension Widget {
  public class ScrollBar: LeafWidget {
    private let orientation: Orientation

    @ExperimentalStyleProperty
    public var xBarHeight: Double = 40
    @ExperimentalStyleProperty
    public var yBarWidth: Double = 40

    @State
    public var scrollProgress = 0.0
    public var maxScrollProgress = 0.0

    var trackLength: Double {
      let trackLengthBase: Double
      switch orientation {
      case .horizontal: trackLengthBase = layoutedSize.width
      case .vertical: trackLengthBase = layoutedSize.height
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
        _ = onDestroy(rootParent.onMouseMoveHandlerManager.addHandler(handleMouseMove))
      }
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      constraints.constrain(DSize2(yBarWidth, xBarHeight))
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

    override public func draw(_ drawingContext: DrawingContext) {
      let trackOffset = trackLength * scrollProgress

      let trackRect: DRect
      switch orientation {
      case .horizontal:
        trackRect = DRect(min: DVec2(trackOffset, 0), size: DSize2(trackLength, layoutedSize.height))
      case .vertical:
        trackRect = DRect(min: DVec2(0, trackOffset), size: DSize2(layoutedSize.width, trackLength))
      }
      drawingContext.drawRect(rect: trackRect, paint: Paint(color: foreground))
    }

    public enum Orientation {
      case horizontal, vertical
    }
  }
}