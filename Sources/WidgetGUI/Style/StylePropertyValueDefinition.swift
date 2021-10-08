import OpenCombine

public struct StylePropertyValueDefinition {
  public var keyPath: AnyKeyPath
  public var value: Value

  public enum Value {
    case constant(AnyStylePropertyValue)
    /// expecting a value with type AnyReactiveProperty<correct value type>
    /// wherever this enum type is used must ensure value in reactive is
    /// as expected by the style processing logic (need to do type check before
    /// erasing type!)
    case reactive(Any)
  }
}