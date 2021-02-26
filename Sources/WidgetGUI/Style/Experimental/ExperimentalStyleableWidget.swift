public protocol ExperimentalStyleableWidget: ExperimentalAnyStyleableWidget {
  associatedtype SpecialStylePropertiesStorage: ExperimentalPartialStylePropertiesStorage
}

extension ExperimentalStyleableWidget {
  public typealias SpecialStylePropertyValues = Experimental.StylePropertyValues<SpecialStylePropertiesStorage>

  public func experimentalWith(@Experimental.StylePropertyValueDefinitionsBuilder<SpecialStylePropertiesStorage> styleProperties buildDefinitions: () -> [Experimental.StylePropertyValueDefinition]) -> Self {
    self.experimentalDirectStylePropertyValueDefinitions.append(contentsOf: buildDefinitions())
    return self
  }

  public func getSpecialStylePropertyValuesType() -> ExperimentalAnyStylePropertyValues.Type {
    SpecialStylePropertyValues.self
  }

  /*public func stylePropertyValue<T>(_ keyPath: KeyPath<SpecialStylePropertiesStorage, T>) -> T {
    stylePropertiesResolver.experimentalPropertyValues[keyPath: keyPath]
  }*/
}

public protocol ExperimentalAnyStyleableWidget: Widget {
  func getSpecialStylePropertyValuesType() -> ExperimentalAnyStylePropertyValues.Type
}