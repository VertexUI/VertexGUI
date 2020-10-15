// TODO: maybe rename to avoid confusion between swifts static and the meaning of static as not changing here
public class StaticProperty<V>: ObservableProperty<V> {
  private var _value: Value
  override public var value: Value {
    _value
  }

  public init(_ value: Value) {
    self._value = value
  }
}