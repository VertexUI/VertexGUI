import GfxMath

public protocol DrawingSurface {
  var size: DSize2 { get }
  var resolution: Double { get }
}