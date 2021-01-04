import GfxMath

public protocol AnyPaddingStyleProperties: AnyStyleProperties {
  var padding: Insets? { get }
}

public struct PaddingStyleProperties: StyleProperties, AnyPaddingStyleProperties {
  @StyleProperty
  public var padding: Insets?

  public init() {}
}