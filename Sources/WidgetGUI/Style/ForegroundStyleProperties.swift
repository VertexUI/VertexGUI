import VisualAppBase
import GfxMath

public protocol AnyForegroundStyleProperties: AnyStyleProperties {
  var foreground: Color? { get set }
}

public protocol ForegroundStyleProperties: AnyForegroundStyleProperties, StyleProperties {

}

public struct SimpleForegroundStyleProperties: ForegroundStyleProperties {
  @StyleProperty
  public var foreground: Color?

  public init() {}
}
