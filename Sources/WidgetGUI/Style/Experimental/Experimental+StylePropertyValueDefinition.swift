extension Experimental {
  public struct StylePropertyValueDefinition {
    public var keyPath: AnyKeyPath
    public var value: AnyStylePropertyValue
    //public var write: (ExperimentalPartialStylePropertiesStorage, Any) -> ExperimentalPartialStylePropertiesStorage 
  }
}