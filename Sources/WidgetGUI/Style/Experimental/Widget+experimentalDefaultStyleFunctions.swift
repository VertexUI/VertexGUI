extension Widget {
  public func experimentalWith(@Experimental.StylePropertyValueDefinitionsBuilder<Experimental.EmptyStylePropertiesStorage> styleProperties build: () -> [Experimental.StylePropertyValueDefinition]) -> Widget {
    self.experimentalDirectStylePropertyValueDefinitions.append(contentsOf: build())
    return self
  }

  public func getStylePropertyValuesType() -> ExperimentalAnyStylePropertyValues.Type {
    if let styleable = self as? ExperimentalAnyStyleableWidget {
      return styleable.getSpecialStylePropertyValuesType()
    } else {
      return Experimental.StylePropertyValues<Experimental.EmptyStylePropertiesStorage>.self
    }
  }
}