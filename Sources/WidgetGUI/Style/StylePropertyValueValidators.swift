public struct StylePropertyValueValidators {
  public var typeValidator: TypeValidator
  public var valueValidator: ValueValidator?

  public init(typeValidator: TypeValidator, valueValidator: ValueValidator? = nil) {
    self.typeValidator = typeValidator
    self.valueValidator = valueValidator
  }

  public func validateType(_ value: Any) -> Bool {
    switch typeValidator {
    case let .specific(validType):
      return ObjectIdentifier(validType) == ObjectIdentifier(type(of: value))
    case let .function(validate):
      return validate(value)
    }
  }

  public func validateValue(_ value: Any) -> Bool {
    if let validate = valueValidator {
      return validate(value)
    }
    return true
  }

  public enum TypeValidator {
    case specific(_ type: StyleValue.Type)
    case function(_ validate: (Any) -> Bool)
  }

  public typealias ValueValidator = (Any) -> Bool
}