import VisualAppBase
import GfxMath

extension Widget {
  internal func drawScrollbars(_ drawingContext: DrawingContext) {
    if scrollingEnabled.y {
      let scrollBarBounds = DRect(min: DVec2(width - pseudoScrollBarY.width, 0), max: DVec2(width, height))

      drawingContext.drawRect(
        rect: scrollBarBounds,
        paint: Paint(color: pseudoScrollBarY.background))

      let trackLength = height / (height + maxScrollOffset.y - minScrollOffset.y) * height
      let trackOffset = -currentScrollOffset.y / (height + maxScrollOffset.y - minScrollOffset.y) * height

      drawingContext.drawRect(
        rect: DRect(min: DVec2(scrollBarBounds.min.x, trackOffset), max: DVec2(scrollBarBounds.max.x, trackOffset + trackLength)),
        paint: Paint(color: pseudoScrollBarY.track)
      )
    }
  }
}