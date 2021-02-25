import ReactiveProperties
import Events

public class Dynamic<C: ExpContentProtocol> {
  var associatedStyleScope: UInt

  let content: C

  var dependencyProxies: [AnyReactiveProperty]
  let onDependenciesChanged = EventHandlerManager<Void>()

  // have dependency: as part of function signature
  // because the specific initializers in the extensions
  // do not, this prevenets the specific initializer from
  // calling itself
  private init<P: ReactiveProperty>(dependency: P, build: @escaping () -> [C.Partial]) {
    let proxy = ObservableProperty<P.Value>()
    proxy.bind(dependency)
    self.dependencyProxies = [proxy]

    self.associatedStyleScope = Widget.activeStyleScope

    let partials = build()
    self.content = C(partials: partials)
    
    _ = proxy.onChanged { [unowned self] _ in
      onDependenciesChanged.invokeHandlers()
    }

    // don't need to update content anymore after it is destroyed
    // it's necessary to manual destroy because this Dynamic object
    // is captured within the handler, to avoid early deallocation
    _ = content.onDestroy(onDependenciesChanged { [unowned content] in
      Widget.inStyleScope(self.associatedStyleScope) {
        self.content.partials = build()
      }
    })
  }

  deinit {
    print("DEINIT DYNAMIC")
  }
}

extension Dynamic where C == ExpDirectContent {
  public convenience init<P: ReactiveProperty>(_ dependency: P, @ExpDirectContentBuilder build: @escaping () -> [C.Partial]) {
    self.init(dependency: dependency, build: build)
  }
}

extension Dynamic where C == ExpSlottingContent {
  public convenience init<P: ReactiveProperty>(_ dependency: P, @ExpSlottingContentBuilder build: @escaping () -> [C.Partial]) {
    self.init(dependency: dependency, build: build)
  }
}