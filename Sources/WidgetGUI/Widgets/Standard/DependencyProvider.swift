public class DependencyProvider: SingleChildWidget {
  public internal(set) var dependencies: [Dependency]
  private var childBuilder: () -> Widget

  public init(
    provide dependencies: [Dependency], @WidgetBuilder child childBuilder: @escaping () -> Widget
  ) {
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

public struct Dependency {
  public internal(set) var value: Any
  public internal(set) var id: String?
  public init<T>(_ value: T, id: String? = nil) {
    self.value = value
    self.id = id
  }
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
        fatalError(
          "Tried to set value of Inject to different type than specified. Specified type: \(T.self), got new value: \(String(describing: newValue))."
        )
      }
    }
  }

  var anyType: Any.Type = T.self

  public var wrappedValue: T {
    return value!
  }

  public init() {}
}

internal protocol AnyInject: class, _AnyInject {}

/**
Warning: Do not directly conform to this protocol. Instead conform to AnyInject.
This is necessary to get reference semantics for the Inject containers. Use _AnyInject only
to check whether some property of a class is an Inject container. _AnyInject can not define : class, because
this crashes Swift because of some NSObject conversion.
*/
internal protocol _AnyInject {
  var anyType: Any.Type { get }
  var anyValue: Any? { get set }
}
