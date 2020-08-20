public struct Dependency {
    public internal(set) var value: Any
    public internal(set) var id: String?

    public init<T>(_ value: T, id: String? = nil) {
        self.value = value
        self.id = id
    }
}

internal protocol AnyInject: class {
    var anyType: Any.Type { get }
    var anyValue: Any? { get set }
}

@propertyWrapper
public class Inject<T>: AnyInject {
    public typealias Value = T

    internal var value: T? = nil

    internal var anyValue: Any? {
        get {
            return value
        }

        set {
            if let newValue = newValue as? T {
                value = newValue
            } else {
                fatalError("Tried to set value of Inject to different type than specified. Specified type: \(T.self), got new value: \(newValue).")
            }
        }
    }

    var anyType: Any.Type = T.self

    public var wrappedValue: T {
        get {
            return value!
        }
    }

    public init() {}
}

public class DependencyProvider: SingleChildWidget {
    public internal(set) var dependencies: [Dependency]
    
    private var childBuilder: () -> Widget

    public init(provide dependencies: [Dependency], @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        self.dependencies = dependencies
        self.childBuilder = childBuilder
    }

    override public func buildChild() -> Widget {
        childBuilder()
    }

    public func getDependency(ofType requestedType: Any.Type) -> Dependency? {

        for dependency in dependencies {
            
            if type(of: dependency.value) == requestedType {
        
                return dependency
            }
        }

        return nil
    }
}