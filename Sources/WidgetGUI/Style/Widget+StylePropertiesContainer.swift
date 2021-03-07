public protocol ExperimentalStylePropertiesContainer: Widget {}

extension ExperimentalStylePropertiesContainer {
  public typealias ExperimentalStyleProperty<Value> = Experimental.SpecialStyleProperty<Self, Value>

  public func experimentalWith(@Experimental.StylePropertyValueDefinitionsBuilder<Self> styleProperties build: () -> [Experimental.StylePropertyValueDefinition]) -> Self {
    self.experimentalDirectStylePropertyValueDefinitions.append(contentsOf: build())
    return self
  }

  public func setupExperimentalStyleProperties() {
    let mirror = Mirror(reflecting: self)
    for child in mirror.allChildren {
      if var property = child.value as? ExperimentalAnyStylePropertyProtocol {
        property.container = self
        property.name = child.label
      }
    }
  }
}

extension Widget: ExperimentalStylePropertiesContainer {}