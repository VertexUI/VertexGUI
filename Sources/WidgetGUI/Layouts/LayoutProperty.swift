@propertyWrapper
public class LayoutProperty<T>: AnyLayoutProperty {
  private var keyPath: KeyPath<Container, Experimental.SpecialStyleProperty<Container, T>>
  unowned var layoutInstance: Layout? {
    didSet {
      setupBinding()
    }
  }
  var removeBinding: (() -> ())? = nil

  public var wrappedValue: T {
    layoutInstance!.container[keyPath: keyPath].resolvedValue
  }

  public init(_ keyPath: KeyPath<Container, Experimental.SpecialStyleProperty<Container, T>>) {
    self.keyPath = keyPath
  }

  func setupBinding() {
    removeBinding?()
    // DANGLING HANDLER
    removeBinding = layoutInstance!.container[keyPath: keyPath].observable.onChanged { [unowned self] _ in
      layoutInstance!.container.invalidateLayout()
    }
  }

  deinit {
    removeBinding?()
  }
}

internal protocol AnyLayoutProperty: class {
  var layoutInstance: Layout? { get set }
}