public protocol StylePropertiesContainer: Widget {}

extension StylePropertiesContainer {
  public typealias StyleProperty<V> = WidgetGUI.AnySpecialStyleProperty<Self, V>

  public func with(@StylePropertyValueDefinitionsBuilder<Self> styleProperties build: () -> [StylePropertyValueDefinition]) -> Self {
    self.DirectStylePropertyValueDefinitions.append(contentsOf: build())
    return self
  }

  public func setupStyleProperties() {
    let mirror = Mirror(reflecting: self)
    for child in mirror.allChildren {
      if var property = child.value as? AnyStylePropertyProtocol {
        property.container = self
        property.name = child.label
      }
    }
  }
}

extension Widget: StylePropertiesContainer {}