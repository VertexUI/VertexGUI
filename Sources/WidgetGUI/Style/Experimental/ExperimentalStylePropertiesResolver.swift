import ExperimentalReactiveProperties
import Events

extension Experimental {
  public class StylePropertiesResolver {
    public var propertySupportDefinitions: Experimental.StylePropertySupportDefinitions
    public var styles: [Experimental.Style] = []
    public var directProperties: [Experimental.StyleProperties] = []
    public var inheritableValues: [String: StyleValue?] = [:]

    internal var resolvedPropertyValues: [String: StyleValue?] = [:] {
      didSet {
        // TODO: only update for actually changed values
        // TODO: maybe all of this logic should be put below resolve()?
        for (key, basis) in observableBases {
          let newValue = resolvedPropertyValues[key] ?? nil
          basis.value = newValue
        }
        onResolvedPropertyValuesChanged.invokeHandlers((old: oldValue, new: resolvedPropertyValues))
      }
    }
    /** used as backing for ObservableProperties for resolved values */
    private var observableBases: [String: MutableProperty<StyleValue?>] = [:]
    private var observableHandlerRemovers: [String: [() -> ()]] = [:]
    private var ownedObjects: [AnyObject] = []

    public let onResolvedPropertyValuesChanged = EventHandlerManager<(old: [String: StyleValue?], new: [String: StyleValue?])>()

    private var widget: Widget?

    public init(propertySupportDefinitions: Experimental.StylePropertySupportDefinitions, widget: Widget? = nil) {
      self.propertySupportDefinitions = propertySupportDefinitions
      self.widget = widget
    }

    public subscript(_ key: StyleKey) -> StyleValue? {
      resolvedPropertyValues[key.asString] ?? nil
    }

    public subscript<T>(_ key: StyleKey) -> T? {
      self[key] as? T
    }

    private func getBasisForObservable(key: StyleKey) -> MutableProperty<StyleValue?> {
      let observableBasis: MutableProperty<StyleValue?>
      if let basis = observableBases[key.asString] {
        observableBasis = basis
      } else {
        observableBasis = MutableProperty<StyleValue?>(self[key.asString])
        observableBases[key.asString] = observableBasis
      }
      return observableBasis
    }

    public subscript<T: StyleValue>(reactive key: StyleKey) -> ExperimentalReactiveProperties.ObservableProperty<T?> {
      let observableBasis = getBasisForObservable(key: key)

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

    public subscript(reactive key: StyleKey) -> ExperimentalReactiveProperties.ObservableProperty<StyleValue?> {
      let observableBasis = getBasisForObservable(key: key)

      let observable = ExperimentalReactiveProperties.ObservableProperty<StyleValue?>()
      observable.bind(observableBasis)

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
        //let propertyDefinition = propertySupportDefinitions[key]

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
              updateSingleResolvedValue(key: key, newValue: reactiveProperty.value)
            },
            reactiveProperty.onChanged { [unowned self] in
              updateSingleResolvedValue(key: key, newValue: $0.new)
            }
          ])
        } 
      }
      for propertyDefinition in propertySupportDefinitions {
        resolvedValues[propertyDefinition.key.asString] = resolvedValues[propertyDefinition.key.asString] ?? propertyDefinition.defaultValue
      }
      for (key, value) in resolvedValues {
        resolvedValues[key] = inheritOrKeepCurrent(value: value, for: key)
      }

      self.resolvedPropertyValues = resolvedValues
    }

    private func updateSingleResolvedValue(key: StyleKey, newValue: StyleValue?) {
      var processed = newValue ?? propertySupportDefinitions[key.asString]?.defaultValue
      processed = inheritOrKeepCurrent(value: processed, for: key)
      resolvedPropertyValues[key.asString] = processed
    }

    private func inheritOrKeepCurrent(value: StyleValue?, for key: StyleKey) -> StyleValue? {
      if let special = value as? SpecialStyleValue {
        if special == .inherit {
          return inheritableValues[key.asString] ?? nil
        }
      }
      return value
    }
  }
}