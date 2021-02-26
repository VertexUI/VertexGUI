public protocol ExperimentalStylePropertiesContainer: Widget {}

extension ExperimentalStylePropertiesContainer {
  public typealias ExperimentalStyleProperty<Value> = Experimental.SpecialStyleProperty<Self, Value>

  public func experimentalWith(@Experimental.StylePropertyValueDefinitionsBuilder<Self> styleProperties build: () -> [Experimental.StylePropertyValueDefinition]) -> Widget {
    self.experimentalDirectStylePropertyValueDefinitions.append(contentsOf: build())
    return self
  }
}

extension Widget: ExperimentalStylePropertiesContainer {}