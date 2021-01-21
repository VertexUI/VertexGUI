import ExperimentalReactiveProperties
import Events

extension Experimental {
  public class StylePropertiesResolver {
    public var propertySupportDefinitions: Experimental.StylePropertySupportDefinitions
    public var styles: [Experimental.Style] = []
    public var directProperties: [Experimental.StyleProperties] = []

    private var resolvedPropertyValues: [String: StyleValue?] = [:] {
      didSet {
        onResolvedPropertyValuesChanged.invokeHandlers(resolvedPropertyValues)

        // TODO: only update for actually changed values
        // TODO: maybe all of this logic should be put below resolve()?
        for (key, basis) in observableBases {
          let newValue = resolvedPropertyValues[key] ?? nil
          if Self.loggingEnabled {
            print(Self.loggingPrefix, widgetIdentifier, "updating observable basis for key", key, "with value", newValue)
          }
          basis.value = newValue
        }
      }
    }
    /** used as backing for ObservableProperties for resolved values */
    private var observableBases: [String: MutableProperty<StyleValue?>] = [:]
    private var observableHandlerRemovers: [String: [() -> ()]] = [:]
    private var ownedObjects: [AnyObject] = []

    public let onResolvedPropertyValuesChanged = EventHandlerManager<[String: StyleValue?]>()

    private static var loggingPrefix = "RESOLVER::::::"
    private static var loggingEnabled = false
    private var widget: Widget?
    private var widgetIdentifier: String {
      if let widget = widget {
        return String(describing: widget) + " " + String(widget.id)
      } else {
        return ""
      }
    }

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

      if Self.loggingEnabled {
        print(Self.loggingPrefix, widgetIdentifier, "created a typed observable property to reference the value for", key, "with id", observable.id)
      }

      return observable
    }

    public subscript(reactive key: StyleKey) -> ExperimentalReactiveProperties.ObservableProperty<StyleValue?> {
      if Self.loggingEnabled {
        print(Self.loggingPrefix, widgetIdentifier, "creating an observable property to reference the value for", key)
      }
      let observableBasis = getBasisForObservable(key: key)
      _ = observableBasis.onChanged { [unowned self] in
        if Self.loggingEnabled {
          print(Self.loggingPrefix, widgetIdentifier, "the basis for observable properties with key", key, "changed to value", $0.new)
        }
      }

      let observable = ExperimentalReactiveProperties.ObservableProperty<StyleValue?>()
      _ = observable.onChanged { [unowned self] in
        if Self.loggingEnabled {
          print(Self.loggingPrefix, widgetIdentifier, "an observable for the property", key, "changed to value", $0.new)
        }
      }
      observable.bind(observableBasis)

      if Self.loggingEnabled {
        print(Self.loggingPrefix, widgetIdentifier, "created an untyped observable property to reference the value for", key, "with id", observable.id)
      }

      return observable 
    }

    public func resolve() {
      if Self.loggingEnabled {
          print("--------------------------------------")
          print(Self.loggingPrefix, widgetIdentifier, "start resolving")
      }
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
        if Self.loggingEnabled {
          print(Self.loggingPrefix, widgetIdentifier, "got property for key", key)
        }

        switch property.value {
        case let .static(value):
          if Self.loggingEnabled {
            print(Self.loggingPrefix, widgetIdentifier, "is static property with value", value)
          }
          resolvedValues[key] = value
        case let .reactive(reactiveProperty):
          if Self.loggingEnabled {
            print(Self.loggingPrefix, widgetIdentifier, "is reactive property with id", reactiveProperty.id)
          }
          if reactiveProperty.hasValue {
            if Self.loggingEnabled {
              print(Self.loggingPrefix, widgetIdentifier, "has a value", reactiveProperty.value)
            }
            resolvedValues[key] = reactiveProperty.value
          } else {
            if Self.loggingEnabled {
              print(Self.loggingPrefix, widgetIdentifier, "does not have a value")
            }
            resolvedValues[key] = nil
          }

          _ = reactiveProperty.onDestroyed { [unowned self] in
            if Self.loggingEnabled {
              print(Self.loggingPrefix, widgetIdentifier, "reactive property destroyed")
            }
          }

          if observableHandlerRemovers[key] == nil {
            observableHandlerRemovers[key] = []
          }
          observableHandlerRemovers[key]!.append(contentsOf: [
            reactiveProperty.onHasValueChanged { [unowned self, unowned reactiveProperty] in
              if Self.loggingEnabled {
                print(Self.loggingPrefix, widgetIdentifier, "reactive property hasValue changed", key, reactiveProperty.value)
              }
              resolvedPropertyValues[key] = reactiveProperty.value
            },
            reactiveProperty.onChanged { [unowned self] in
              if Self.loggingEnabled {
                print(Self.loggingPrefix, widgetIdentifier, "reactive property value changed", key, reactiveProperty.value)
              }
              resolvedPropertyValues[key] = $0.new
            }
          ])
        } 
      }

      self.resolvedPropertyValues = resolvedValues
    }
  }
}