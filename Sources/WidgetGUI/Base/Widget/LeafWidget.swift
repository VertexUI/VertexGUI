import VisualAppBase

public protocol LeafWidgetProtocol: Widget {
  func draw(_ drawingContext: DrawingContext)
}