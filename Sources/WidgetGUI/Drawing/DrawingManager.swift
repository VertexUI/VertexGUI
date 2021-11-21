import GfxMath
import SkiaKit
import Drawing

public class DrawingManager {
  unowned let root: Root
  var rootWidget: Widget

  private let debugFontSize = 16.0
  lazy private var debugFont = createDebugFont()

  public init(root: Root, rootWidget: Widget) {
    self.root = root
    self.rootWidget = rootWidget
  }

  public func processQueue(_ queue: Widget.LifecycleMethodInvocationQueue, drawingContext: DrawingContext, canvas: SkiaKit.Canvas) {
    /*var iterationStates = [(Parent?, DrawingContext, CanvasState, Array<Widget>.Iterator)]()
    iterationStates.append((nil, drawingContext, CanvasState(), [rootWidget].makeIterator()))*/
    canvas.save()

    var baseCanvasState = CanvasState()
    baseCanvasState.transforms.append(.scale(DVec2(root.scale, root.scale), origin: DVec2(0, 0)))

    var drawStack = [DrawingStackItem]()
    drawStack.append(DrawingStackItem(
      parent: nil,
      parentCanvasState: baseCanvasState,
      childrenIterator: [rootWidget].makeIterator()))

    outer: while var stackItem = drawStack.last {
      while let widget = stackItem.childrenIterator.next() {
        canvas.restore()
        canvas.save()
        //(parent, parentDrawingContext, iterator)
        //iterationStates[iterationStates.count - 1].2 = iterator

        if widget.visibility == .visible && widget.opacity > 0 {
          var canvasState = stackItem.parentCanvasState

         // let childDrawingContext: DrawingContext = parentDrawingContext.clone()
          
          //childDrawingContext.opacity = widget.opacity
          //childDrawingContext.transform(.translate(widget.layoutedPosition))
          //childDrawingContext.transform(widget.transform)
          canvasState.transforms.append(.translate(widget.layoutedPosition * root.scale))
          // TODO: maybe the scrolling translation should be added to the parent widget context before adding the iterator to the list?
          if !widget.unaffectedByParentScroll, let parent = widget.parent as? Widget, parent.overflowX == .scroll || parent.overflowY == .scroll {
            canvasState.transforms.append(.translate(-parent.currentScrollOffset * root.scale))
          }
          
          //childDrawingContext.lock()

          //childDrawingContext.beginDrawing()

          if widget.overflowX == .cut || widget.overflowX == .scroll || widget.overflowY == .cut || widget.overflowY == .scroll {
            let localClipRect = DRect(min: DVec2(0, 0), size: widget.layoutedSize)
            let globalClipRect = canvasState.transforms.transform(rect: localClipRect)
            let combinedClipRect: DRect
            
            if let previousClipRect = canvasState.clipRect {
              combinedClipRect = previousClipRect.intersection(with: globalClipRect) ?? DRect(min: .zero, size: .zero)
            } else {
              combinedClipRect = globalClipRect
            }
            
            canvasState.clipRect = combinedClipRect
          }

          apply(canvasState: canvasState, to: canvas)

          if let clipRect = canvasState.clipRect {
            canvas.clip(region: Region(rect: IRect(
              x: Int32(clipRect.min.x),
              y: Int32(clipRect.min.y),
              width: Int32(clipRect.size.width),
              height: Int32(clipRect.size.height)
            )))
          }

          if widget.background != .transparent {
            //childDrawingContext.drawRect(rect: DRect(min: .zero, size: widget.layoutedSize), paint: Paint(color: widget.background))

            let paint = Paint(color: widget.background, style: .fill, isAntialias: true)
            canvas.drawRect(DRect(min: .zero, size: widget.layoutedSize), paint)
            canvas.flush()
          }

          // TODO: probably the border should be drawn after all children have been drawn, to avoid the border being overlpassed
          if widget.borderColor != .transparent && widget.borderWidth != .zero {
            drawBorders(widget: widget, canvas: canvas)
            canvas.flush()
          }

          if widget.debugLayout, widget is LeafWidget {
            canvas.drawRect(DRect(min: .zero, size: widget.globalBounds.size), Paint.stroke(color: .red, width: 2.0))
            canvas.flush()
          }

          if widget.debugHighlight {
            canvas.drawRect(DRect(min: .zero, size: widget.globalBounds.size), Paint.fill(color: Color(r: 210, g: 210, b: 255, a: 50)))
            canvas.flush()
          }

          if widget.padding.left != 0 || widget.padding.top != 0 {
            //childDrawingContext.transform(.translate(DVec2(widget.padding.left, widget.padding.top)))
            canvasState.transforms.append(.translate(DVec2(widget.padding.left, widget.padding.top) * root.scale))
            apply(canvasState: canvasState, to: canvas)
          }

          //childDrawingContext.lock()

          if let leafWidget = widget as? LeafWidget {
            leafWidget.draw(drawingContext, canvas: canvas)
            canvas.flush()
          }
          
          if !(widget is LeafWidget) {
            //iterationStates.append((widget, childDrawingContext, widget.children.makeIterator()))
            drawStack.append(DrawingStackItem(parent: widget, parentCanvasState: canvasState, childrenIterator: widget.children.makeIterator()))
            continue outer
          }
        }
      }

      // this debug border will only be drawn for non-leaf widgets (after it's sub widgets have been drawn)
      if let parent = stackItem.parent, parent.debugLayout {
        var canvasState = stackItem.parentCanvasState
        canvasState.transforms.append(.translate(-DVec2(parent.padding.left, parent.padding.top)))
        apply(canvasState: canvasState, to: canvas)
        canvas.drawRect(DRect(min: .zero, size: parent.globalBounds.size), Paint.stroke(color: .red, width: 2.0))
        canvas.draw(text: "\(parent.globalBounds.size.width) \(parent.globalBounds.size.height)", x: 0, y: Float(debugFontSize), font: createDebugFont(), paint: createDebugPaint())
        canvas.flush()
      }

      /*if let parent = parent as? Widget, parent.scrollingEnabled.x || parent.scrollingEnabled.y {
        parentDrawingContext.beginDrawing()
        parent.drawScrollbars(parentDrawingContext)
        parentDrawingContext.endDrawing()
      }*/

      //iterationStates.removeLast()
      drawStack.removeLast()
      canvas.restore()
    }

    /*canvas.clear(color: Colors.yellow)
    canvas.translate(dx: 100, dy: 100)
    canvas.drawRect(DRect(min: DVec2(20,20), max: DVec2(1000, 1000)), Paint(color: .black, style: .fill, isAntialias: true))*/
  }

  private func drawBorders(widget: Widget, canvas: Canvas) {
    if widget.borderWidth.top > 0 {
      canvas.drawLine(
        from: DVec2(0, widget.borderWidth.top / 2),
        to: DVec2(widget.layoutedSize.width, widget.borderWidth.top / 2),
        paint: Paint.stroke(color: widget.borderColor, width: widget.borderWidth.top))
    }

    if widget.borderWidth.right > 0 {
      canvas.drawLine(
        from: DVec2(widget.layoutedSize.width - widget.borderWidth.right / 2, 0),
        to: DVec2(widget.layoutedSize.width - widget.borderWidth.right / 2, widget.layoutedSize.height),
        paint: Paint.stroke(color: widget.borderColor, width: widget.borderWidth.right))
    }

    if widget.borderWidth.bottom > 0 {
      canvas.drawLine(
        from: DVec2(0, widget.layoutedSize.height - widget.borderWidth.bottom / 2),
        to: DVec2(widget.layoutedSize.width, widget.layoutedSize.height - widget.borderWidth.bottom / 2),
        paint: Paint.stroke(color: widget.borderColor, width: widget.borderWidth.bottom))
    }

    if widget.borderWidth.left > 0 {
      canvas.drawLine(
        from: DVec2(widget.borderWidth.left / 2, 0),
        to: DVec2(widget.borderWidth.left / 2, widget.layoutedSize.height),
        paint: Paint.stroke(color: widget.borderColor, width: widget.borderWidth.left))
    }
  }

  private func apply(canvasState: CanvasState, to canvas: Canvas) {
    canvas.resetMatrix()
    for transform in canvasState.transforms.reversed() {
      switch transform {
        case let .translate(translation):
          canvas.translate(dx: Float(translation.x), dy: Float(translation.y))
        case let .scale(scale, origin):
          if let origin = origin {
            canvas.scale(sx: Float(scale.x), sy: Float(scale.y), pivot: SkiaKit.Point(FVec2(origin)))
          } else {
            canvas.scale(sx: Float(scale.x), sy: Float(scale.y))
          }
        default:
          break
      }
    }
  }

  private func createDebugPaint() -> SkiaKit.Paint {
    Paint.fill(color: .red)
  }

  private func createDebugFont() -> SkiaKit.Font {
    guard let typeface = Typeface(familyName: "Arial", weight: .normal, width: .normal, slant: .upright) else {
      fatalError("could not create typeface for text widget")
    }

    let font = Font()
    font.size = Float(debugFontSize)
    font.typeface = typeface
    return font
  }

  private struct CanvasState {
    var transforms: [DTransform2] = []
    var clipRect: DRect?

    func transform(point: DVec2) -> DVec2 {
      transforms.transform(point: point)
    }
  }

  private class DrawingStackItem {
    var parent: Widget?
    var parentCanvasState: CanvasState
    var childrenIterator: Array<Widget>.Iterator

    init(parent: Widget?, parentCanvasState: CanvasState, childrenIterator: Array<Widget>.Iterator) {
      self.parent = parent
      self.parentCanvasState = parentCanvasState
      self.childrenIterator = childrenIterator
    }
  }
}