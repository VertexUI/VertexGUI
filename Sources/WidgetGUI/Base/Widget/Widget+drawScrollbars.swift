import VisualAppBase
import GfxMath

extension Widget {
  /*internal func drawScrollbars(_ drawingContext: DrawingContext) {
    var endPosition: DVec2 = DVec2(width, height)
    if scrollingEnabled.x && scrollingEnabled.y {
      endPosition -= DVec2(pseudoScrollBarY.width, pseudoScrollBarX.width)
    }

    if scrollingEnabled.x {
      let scrollBarBounds = DRect(min: DVec2(0, height - pseudoScrollBarX.width), max: DVec2(endPosition.x, height))

      drawingContext.drawRect(
        rect: scrollBarBounds,
        paint: Paint(color: pseudoScrollBarY.background))

      let trackLength = width / (width + maxScrollOffset.x - minScrollOffset.x) * endPosition.x 
      let trackOffset = -currentScrollOffset.x / (width + maxScrollOffset.x - minScrollOffset.x) * endPosition.x 

      drawingContext.drawRect(
        rect: DRect(min: DVec2(trackOffset, scrollBarBounds.min.y), max: DVec2(trackOffset + trackLength, scrollBarBounds.max.y)),
        paint: Paint(color: pseudoScrollBarY.track)
      )
    }

    if scrollingEnabled.y {
      let scrollBarBounds = DRect(min: DVec2(width - pseudoScrollBarY.width, 0), max: DVec2(width, endPosition.y))

      drawingContext.drawRect(
        rect: scrollBarBounds,
        paint: Paint(color: pseudoScrollBarY.background))

      let trackLength = height / (height + maxScrollOffset.y - minScrollOffset.y) * endPosition.y 
      let trackOffset = -currentScrollOffset.y / (height + maxScrollOffset.y - minScrollOffset.y) * endPosition.y 

      drawingContext.drawRect(
        rect: DRect(min: DVec2(scrollBarBounds.min.x, trackOffset), max: DVec2(scrollBarBounds.max.x, trackOffset + trackLength)),
        paint: Paint(color: pseudoScrollBarY.track)
      )
    }

    if scrollingEnabled.x && scrollingEnabled.y {
      drawingContext.drawRect(
        rect: DRect(min: endPosition, max: DVec2(width, height)),
        paint: Paint(color: pseudoScrollBarY.background)
      )
    }
  }*/
}