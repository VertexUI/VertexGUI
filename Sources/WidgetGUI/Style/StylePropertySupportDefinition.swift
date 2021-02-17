public struct StylePropertySupportDefinition {
  public var key: StyleKey
  public var validators: StylePropertyValueValidators
  public var source: Source = .unknown 
  public var defaultValue: StyleValue?

  public init(key: StyleKey, validators: StylePropertyValueValidators, defaultValue: StyleValue? = nil) {
    self.key = key
    self.validators = validators
    self.defaultValue = defaultValue
  }

  public enum Source {
    case unknown, global, parent, local
  }
}