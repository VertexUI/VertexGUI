import ExperimentalReactiveProperties

extension Experimental {
  public class StylePropertiesResolver {
    public var propertySupportDefinitions: Experimental.StylePropertySupportDefinitions
    public var styles: [Experimental.Style] = []
    public var directProperties: [Experimental.StyleProperties] = []

    private var resolvedPropertyValues: [String: StyleValue?] = [:] {
      didSet {
        // TODO: only update for actually changed values
        // TODO: maybe all of this logic should be put below resolve()?
        print("updating observable bases", resolvedPropertyValues)
        for (key, basis) in observableBases {
          print("UPDATING BASSIS FOR KEY", key)
          basis.value = resolvedPropertyValues[key] ?? nil
        }
      }
    }
    /** used as backing for ObservableProperties for resolved values */
    private var observableBases: [String: MutableProperty<StyleValue?>] = [:]
    private var observableHandlerRemovers: [String: [() -> ()]] = [:]
    private var ownedObjects: [AnyObject] = []

    public init(propertySupportDefinitions: Experimental.StylePropertySupportDefinitions) {
      self.propertySupportDefinitions = propertySupportDefinitions
    }

    public subscript(_ key: StyleKey) -> StyleValue? {
      resolvedPropertyValues[key.asString] ?? nil
    }

    public subscript<T>(_ key: StyleKey) -> T? {
      self[key] as? T
    }

    public subscript<T: StyleValue>(reactive key: StyleKey) -> ExperimentalReactiveProperties.ObservableProperty<T?> {
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
      ownedObjects.append(typeComputed)

      let observable = ExperimentalReactiveProperties.ObservableProperty<T?>()
      observable.bind(typeComputed)
      _ = observable.onDestroyed { [unowned self] in
        ownedObjects.removeAll { $0 === typeComputed }
      }

      return observable
    }

    public func resolve() {
      for remove in observableHandlerRemovers.values.flatMap { $0 } {
        remove()
      }

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

      var resolvedValues = [String: StyleValue?]()
      for (key, property) in mergedProperties {
        switch property.value {
        case let .static(value):
          resolvedValues[key] = value
        case let .reactive(reactiveProperty):
          if reactiveProperty.hasValue {
            resolvedValues[key] = reactiveProperty.value
          } else {
            resolvedValues[key] = nil
          }

          if observableHandlerRemovers[key] == nil {
            observableHandlerRemovers[key] = []
          }
          observableHandlerRemovers[key]!.append(contentsOf: [
            reactiveProperty.onHasValueChanged { [unowned self, unowned reactiveProperty] in
              resolvedPropertyValues[key] = reactiveProperty.value
              print("PROPERTY WITH KEY", key, "has value changed")
            },
            reactiveProperty.onChanged { [unowned self] in
              resolvedPropertyValues[key] = $0.new
              print("PROPERTY WITH KEY", key, "changed")
            }
          ])
        } 
      }

      self.resolvedPropertyValues = resolvedValues
    }
  }
}