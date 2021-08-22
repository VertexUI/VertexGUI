@propertyWrapper
public class Inject<T>: AnyInject {
  public typealias Value = T

  internal var key: String? = nil

  internal var value: T? = nil
  internal var anyValue: Any? {
    get {
      return value
    }

    set {
      if let newValue = newValue as? T {
        value = newValue
      } else {
        fatalError(
          "Tried to set value of Inject to different type than specified. Specified type: \(T.self), got new value: \(String(describing: newValue))."
        )
      }
    }
  }

  var anyType: Any.Type = T.self

  public var wrappedValue: T {
    if case let .some(value) = value {
      return value
    } else {
      fatalError("a dependency declared with @Inject was not resolved before it's value was accessed")
    }
  }

  public init(key: String? = nil) {
    self.key = key
  }
}

internal protocol AnyInject: AnyObject, _AnyInject {}

/**
Warning: Do not directly conform to this protocol. Instead conform to AnyInject.
This is necessary to get reference semantics for the Inject containers. Use _AnyInject only
to check whether some property of a class is an Inject container. _AnyInject can not define : AnyObject, because
this crashes Swift because of some NSObject conversion.
*/
internal protocol _AnyInject {
  var key: String? { get }
  var anyType: Any.Type { get }
  var anyValue: Any? { get set }
}

