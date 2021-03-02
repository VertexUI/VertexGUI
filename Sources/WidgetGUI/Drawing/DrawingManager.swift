import VisualAppBase
import GfxMath

public class DrawingManager {
  var rootWidget: Widget

  public init(rootWidget: Widget) {
    self.rootWidget = rootWidget
  }

  public func processQueue(_ queue: Widget.LifecycleMethodInvocationQueue, drawingContext: DrawingContext) {
    var iterationStates = [(Parent?, DrawingContext, Array<Widget>.Iterator)]()
    iterationStates.append((nil, drawingContext, [rootWidget].makeIterator()))

    outer: while var (parent, parentDrawingContext, iterator) = iterationStates.last {
      while let widget = iterator.next() {
        iterationStates[iterationStates.count - 1].2 = iterator

        if widget.visibility == .visible && widget.opacity > 0 {
          let childDrawingContext: DrawingContext = parentDrawingContext.clone()
          
          childDrawingContext.opacity = widget.opacity
          childDrawingContext.transform(.translate(widget.layoutedPosition))
          childDrawingContext.transform(widget.styleTransforms)
          // TODO: maybe the scrolling translation should be added to the parent widget context before adding the iterator to the list?
          if !widget.unaffectedByParentScroll, let parent = widget.parent as? Widget, parent.overflowX == .scroll || parent.overflowY == .scroll {
            childDrawingContext.transform(.translate(-parent.currentScrollOffset))
          }
          if widget.overflowX == .cut || widget.overflowX == .scroll || widget.overflowY == .cut || widget.overflowY == .scroll {
            let translationTestRect = drawingContext.preprocess(DRect(min: .zero, size: widget.layoutedSize))
            var clipRect = translationTestRect

            if widget.overflowX == .cut || widget.overflowX == .scroll {
              clipRect.min.x = 0
              clipRect.size.x = widget.layoutedSize.width
            }
            if widget.overflowY == .cut || widget.overflowY == .scroll {
              clipRect.min.y = 0
              clipRect.size.y = widget.layoutedSize.height
            }

            childDrawingContext.clip(rect: clipRect)
          }
          childDrawingContext.lock()

          childDrawingContext.beginDrawing()

          if widget.background != .transparent {
            childDrawingContext.drawRect(rect: DRect(min: .zero, size: widget.layoutedSize), paint: Paint(color: widget.background))
          }

          // TODO: probably the border should be drawn after all children have been drawn, to avoid the border being overlpassed
          if widget.borderColor != .transparent && widget.borderWidth != .zero {
            drawBorders(childDrawingContext, widget: widget)
          }

          if widget.padding.left != 0 || widget.padding.top != 0 {
            childDrawingContext.transform(.translate(DVec2(widget.padding.left, widget.padding.top)))
          }

          childDrawingContext.lock()

          if let leafWidget = widget as? LeafWidget {
            leafWidget.draw(childDrawingContext)
          }

          childDrawingContext.endDrawing()

          if !(widget is LeafWidget) {
            iterationStates.append((widget, childDrawingContext, widget.children.makeIterator()))
            continue outer
          }
        }
      }

      if let parent = parent as? Widget, parent.debugLayout {
        drawingContext.drawRect(rect: parent.globalBounds, paint: Paint(strokeWidth: 2.0, strokeColor: .red))
      }

      /*if let parent = parent as? Widget, parent.scrollingEnabled.x || parent.scrollingEnabled.y {
        parentDrawingContext.beginDrawing()
        parent.drawScrollbars(parentDrawingContext)
        parentDrawingContext.endDrawing()
      }*/

      iterationStates.removeLast()
    }
  }

  private func drawBorders(_ drawingContext: DrawingContext, widget: Widget) {
    if widget.borderWidth.top > 0 {
      drawingContext.drawLine(
        from: DVec2(0, widget.borderWidth.top / 2),
        to: DVec2(widget.layoutedSize.width, widget.borderWidth.top / 2),
        paint: Paint(strokeWidth: widget.borderWidth.top, strokeColor: widget.borderColor))
    }

    if widget.borderWidth.right > 0 {
      drawingContext.drawLine(
        from: DVec2(widget.layoutedSize.width - widget.borderWidth.right / 2, 0),
        to: DVec2(widget.layoutedSize.width - widget.borderWidth.right / 2, widget.layoutedSize.height),
        paint: Paint(strokeWidth: widget.borderWidth.right, strokeColor: widget.borderColor))
    }

    if widget.borderWidth.bottom > 0 {
      drawingContext.drawLine(
        from: DVec2(0, widget.layoutedSize.height - widget.borderWidth.bottom / 2),
        to: DVec2(widget.layoutedSize.width, widget.layoutedSize.height - widget.borderWidth.bottom / 2),
        paint: Paint(strokeWidth: widget.borderWidth.bottom, strokeColor: widget.borderColor))
    }

    if widget.borderWidth.left > 0 {
      drawingContext.drawLine(
        from: DVec2(widget.borderWidth.left / 2, 0), to: DVec2(widget.borderWidth.left / 2, widget.layoutedSize.height),
        paint: Paint(strokeWidth: widget.borderWidth.left, strokeColor: widget.borderColor))
    }
  }
}