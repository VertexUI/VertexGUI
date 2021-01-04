import VisualAppBase
import GfxMath

public protocol AnyBackgroundStyleProperties: AnyStyleProperties {
  var background: Color? { get set }
}

public struct BackgroundStyleProperties: StyleProperties, AnyBackgroundStyleProperties {
  @StyleProperty
  public var background: Color?

  public init() {}
}
