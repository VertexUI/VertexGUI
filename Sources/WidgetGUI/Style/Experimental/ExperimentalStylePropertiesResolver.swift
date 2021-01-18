import ExperimentalReactiveProperties

extension Experimental {
  public class StylePropertiesResolver {
    public var propertySupportDefinitions: Experimental.StylePropertySupportDefinitions
    public var styles: [Experimental.Style] = []
    public var directProperties: [Experimental.StyleProperties] = []

    private var resolvedPropertyValues: [String: StyleValue] = [:] {
      didSet {
        // TODO: only update for actually changed values
        for (key, basis) in observableBases {
          basis.value = resolvedPropertyValues[key]
        }
      }
    }
    /** used as backing for ObservableProperties for resolved values */
    private var observableBases: [String: MutableProperty<StyleValue?>] = [:]

    public init(propertySupportDefinitions: Experimental.StylePropertySupportDefinitions) {
      self.propertySupportDefinitions = propertySupportDefinitions
    }

    public subscript(_ key: StyleKey) -> StyleValue? {
      resolvedPropertyValues[key.asString]
    }

    public subscript<T>(_ key: StyleKey) -> T? {
      self[key] as? T
    }

    public subscript<T: StyleValue & Equatable>(reactive key: StyleKey) -> ExperimentalReactiveProperties.ObservableProperty<T?> {
      let observableBasis: MutableProperty<StyleValue?>
      if let basis = observableBases[key.asString] {
        observableBasis = basis
      } else {
        observableBasis = MutableProperty<StyleValue?>(self[key.asString])
        observableBases[key.asString] = observableBasis
      }

      let typeComputed = ComputedProperty(compute: {
        observableBasis.value as? T
      }, dependencies: [observableBasis])

      let observable = ExperimentalReactiveProperties.ObservableProperty<T?>()
      observable.bind(typeComputed)

      return observable
    }

    public func resolve() {
      var mergedProperties = [String: Experimental.StyleProperty]()

      for style in styles {
        for property in style.properties {
          mergedProperties[property.key.asString] = property
        }
      }

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