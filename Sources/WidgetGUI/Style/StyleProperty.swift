import GfxMath

public protocol AnyStyleProperty: class {
  var anyValue: Any? { get set }
}

@propertyWrapper
public class StyleProperty<Value: Equatable>: AnyStyleProperty {
  public var wrappedValue: Value?

  public var anyValue: Any? {
    get {
      return wrappedValue
    }

    set {
      if newValue == nil {
        wrappedValue = nil
      } else {
        wrappedValue = newValue as! Value
      } 
    }
  }

  public init(wrappedValue: Value?) {
    self.wrappedValue = nil
  }
}