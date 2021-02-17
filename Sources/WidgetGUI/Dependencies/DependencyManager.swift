public class DependencyManager {
  public init() {}

  public func processSubTree(rootWidget: Widget) {
    let initialAvailableDependencies = getAvailableDependencies(upTo: rootWidget)

    var iterationStates = [([rootWidget].makeIterator(), initialAvailableDependencies)]

    while iterationStates.count > 0 {
      var (iterator, availableDependencies) = iterationStates.removeFirst()

      while let widget = iterator.next() {
        resolveDependencies(on: widget, available: availableDependencies)

        if widget.children.count > 0 {
          let nextAvailableDependencies = availableDependencies + widget.providedDependencies
          iterationStates.append((widget.children.makeIterator(), nextAvailableDependencies))
        }
      }
    }
  }

  public func resolveDependencies(on widget: Widget) {
    let availableDependencies = getAvailableDependencies(upTo: widget)
    resolveDependencies(on: widget, available: availableDependencies)
  }

  func getAvailableDependencies(upTo widget: Widget) -> [Dependency] {
    var parents = [Widget]()
    var nextParent = widget.parent as? Widget 
    while let parent = nextParent {
      parents.append(parent)
      nextParent = parent.parent as? Widget
    }

    parents.reverse()

    return parents.flatMap { $0.providedDependencies }
  }

  func resolveDependencies(on widget: Widget, available availableDependencies: [Dependency]) {
    let mirror = Mirror(reflecting: widget)
    for child in mirror.children {
      if var inject = child.value as? _AnyInject {
        var resolvedValue: Any? = nil
        if let key = inject.key {
          resolvedValue = availableDependencies.first { $0.key == key }
        } else {
          resolvedValue = availableDependencies.first { ObjectIdentifier(type(of: $0.value)) == ObjectIdentifier(inject.anyType) }?.value
        }
        if let resolvedValue = resolvedValue {
          inject.anyValue = resolvedValue
        }
      }
    }
  }
}