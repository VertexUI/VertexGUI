@propertyWrapper
public class LayoutProperty<T>: AnyLayoutProperty {
  private var key: StyleKey
  unowned var layoutInstance: Layout?

  public var wrappedValue: T {
    layoutInstance!.layoutPropertyValues[key.asString] as! T
  }

  public init(key: StyleKey) {
    self.key = key
  }
}

internal protocol AnyLayoutProperty: class {
  var layoutInstance: Layout? { get set }
}