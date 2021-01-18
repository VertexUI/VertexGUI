extension Experimental {
  public class StylePropertiesResolver {
    public var propertySupportDefinitions: Experimental.StylePropertySupportDefinitions
    public var styles: [Experimental.Style] = []
    public var directProperties: [Experimental.StyleProperties] = []

    private var resolvedPropertyValues: [String: StyleValue] = [:]

    public init(propertySupportDefinitions: Experimental.StylePropertySupportDefinitions) {
      self.propertySupportDefinitions = propertySupportDefinitions
    }

    public subscript(_ key: StyleKey) -> StyleValue? {
      resolvedPropertyValues[key.asString]
    }

    public subscript<T>(_ key: StyleKey) -> T? {
      self[key] as? T
    }

    public func resolve() {
      var mergedProperties = [String: Experimental.StyleProperty]()

      for directProperties in self.directProperties {
        for property in directProperties {
          mergedProperties[property.key.asString] = property
        }
      }

      let resolvedValues = Dictionary(uniqueKeysWithValues: mergedProperties.map { ($0.0, $0.1.value) })

      self.resolvedPropertyValues = resolvedValues
    }
  }
}