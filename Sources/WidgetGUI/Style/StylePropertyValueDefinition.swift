import OpenCombine

public struct StylePropertyValueDefinition {
  public var keyPath: AnyKeyPath
  public var value: Value

  public enum Value {
  case constant(AnyStylePropertyValue)
  case reactive(AnyPublisher<AnyStylePropertyValue, Never>)
  }
}