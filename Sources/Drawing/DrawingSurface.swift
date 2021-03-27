import GfxMath

public protocol DrawingSurface {
  var size: ISize2 { get }
  var resolution: Double { get }

  func getDrawingContext() -> DrawingContext
}