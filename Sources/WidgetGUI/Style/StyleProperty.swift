import GfxMath

public protocol AnyStyleProperty: class {
  var anyValue: Any? { get set }

  static func compareAnyValues(_ value1: Any?, _ value2: Any?) -> Bool
} 

public func == (lhs: AnyStyleProperty, rhs: AnyStyleProperty) -> Bool {
  type(of: lhs) == type(of: rhs) && type(of: lhs).compareAnyValues(lhs.anyValue, rhs.anyValue) 
}

@propertyWrapper
public class StyleProperty<Value: Equatable>: Equatable, AnyStyleProperty {
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

  public static func compareAnyValues(_ value1: Any?, _ value2: Any?) -> Bool {
    if value1 == nil && value2 == nil {
      return true
    } else if let value1 = value1 as? Value, let value2 = value2 as? Value {
      return value1 == value2
    } else {
      return false
    }
  }

  public static func == (lhs: StyleProperty, rhs: StyleProperty) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}