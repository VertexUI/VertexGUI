import VisualAppBase
import GfxMath

public protocol BackgroundStyle: Style {
  var background: Color? { get set }
}

public struct AnyBackgroundStyle: BackgroundStyle {
  public var selector: WidgetSelector? = nil
  @StyleProperty
  public var background: Color?

  public init() {}
}
