import VisualAppBase

open class LeafWidget: Widget {
  open func draw(_ drawingContext: DrawingContext) {
    fatalError("draw() not implemented for widget: \(self)")
  }
}