import VisualAppBase

@propertyWrapper
public class Computed<T> {

    internal var computeValue: (() -> T)? = nil

    internal var dependencies: [AnyObservable] {

        didSet {

            removeDependencyHandlers()

            observeDependencies()
        }
    }

    private var _value: T? = nil

    public var wrappedValue: T {

        get {

            if let value = _value {

                return value
            
            } else {

                updateValue()

                return _value!
            }
        }
    }

    public var value: T {

        get {

            wrappedValue
        }
    }

    public var projectedValue: Observable<T> {

        get {

            let observable = Observable(value)

            _ = onChanged {
                
                observable.value = $0
            }

            return observable
        }
    }

    public internal(set) var onChanged = EventHandlerManager<T>()

    private var dependencyHandlerRemovers: [() -> ()] = []

    public init(_ computeValue: (() -> T)? = nil, dependencies: [AnyObservable] = []) {

        self.computeValue = computeValue

        self.dependencies = dependencies

        observeDependencies()
    }

    deinit {

        onChanged.removeAllHandlers()

        removeDependencyHandlers()
    }

    private func updateValue() {

        if let computeValue = computeValue {

            _value = computeValue()

            // TODO: if T is already an optional, must forward change to nil as well

            if let value = _value {

                onChanged.invokeHandlers(value)
            }
        }
    }

    private func observeDependencies() {
 
        // TODO: might need to check whether any of the dependencies is also a Computed property that depends on this one
        for dependency in dependencies {

            dependencyHandlerRemovers.append(dependency.onChanged { [unowned self] _ in

                updateValue()
            })
        }   
    }

    private func removeDependencyHandlers() {

        for remover in dependencyHandlerRemovers {

            remover()
        }

        dependencyHandlerRemovers = []
    }
}