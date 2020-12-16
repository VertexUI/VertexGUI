import VisualAppBase
import GfxMath

public protocol AnyForegroundStyle: AnyStyle {
  var foreground: Color? { get set }
}

public protocol ForegroundStyle: AnyForegroundStyle, Style {

}

public struct SimpleForegroundStyle: ForegroundStyle {
  public var selector: WidgetSelector? = nil
  @StyleProperty
  public var foreground: Color?

  public init() {}
}
