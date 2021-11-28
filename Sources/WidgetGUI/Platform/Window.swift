import GfxMath

public protocol Window {
  var bounds: DRect { get }
  var screen: Screen { get }
}