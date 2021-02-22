public struct StylePropertySupportDefinition {
  public var key: StyleKey
  public var validators: StylePropertyValueValidators
  public var source: Source = .unknown 
  public var convertValue: ((StyleValue?) -> StyleValue?)? = nil
  public var defaultValue: StyleValue?

  public init(key: StyleKey, validators: StylePropertyValueValidators, convertValue: ((StyleValue?) -> StyleValue?)? = nil, defaultValue: StyleValue? = nil) {
    self.key = key
    self.validators = validators
    self.convertValue = convertValue
    self.defaultValue = defaultValue
  }

  public enum Source {
    case unknown, global, parent, local
  }
}