import VisualAppBase
import GfxMath

public protocol BackgroundStyleProperties: StyleProperties {
  var background: Color? { get set }
}

public struct AnyBackgroundStyleProperties: BackgroundStyleProperties {
  public var selector: WidgetSelector? = nil
  public var subStyles: [AnyStyle]? = nil
  @StyleProperty
  public var background: Color?

  public init() {}
}
