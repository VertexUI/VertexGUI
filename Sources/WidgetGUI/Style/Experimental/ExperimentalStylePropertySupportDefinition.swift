extension Experimental {
  public struct StylePropertySupportDefinition {
    public var key: StyleKey
    public var validators: StylePropertyValueValidators
    public var source: Source = .unknown 

    public init(key: StyleKey, validators: StylePropertyValueValidators) {
      self.key = key
      self.validators = validators
    }

    public enum Source {
      case unknown, global, parent, local
    }
  }
}