import VisualAppBase

public protocol LeafWidget: Widget {
  func draw(_ drawingContext: DrawingContext)
}