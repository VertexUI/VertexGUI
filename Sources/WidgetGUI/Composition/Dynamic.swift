import ReactiveProperties
import Events
import CXShim

public class Dynamic<C: ExpContentProtocol> {
  var associatedStyleScope: UInt

  let content: C

  var dependencyProxies: [AnyReactiveProperty]
  let onDependenciesChanged = EventHandlerManager<Void>()

  var triggerSubscription: AnyCancellable?

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

  private init<P: Publisher>(trigger: P, build: @escaping () -> [C.Partial]) where P.Failure == Never {
    self.dependencyProxies = []

    self.associatedStyleScope = Widget.activeStyleScope

    let partials = build()
    self.content = C(partials: partials)
    
    triggerSubscription = trigger.sink { [unowned self] _ in
      onDependenciesChanged.invokeHandlers()

      Widget.inStyleScope(self.associatedStyleScope) {
        self.content.partials = build()
      }
    }

    // don't need to update content anymore after it is destroyed
    // it's necessary to manual destroy because this Dynamic object
    // is captured within the handler, to avoid early deallocation
    _ = content.onDestroy({ [self] in
      self.triggerSubscription?.cancel()
    })
  }
}

extension Dynamic where C == ExpDirectContent {
  public convenience init<P: ReactiveProperty>(_ dependency: P, @ExpDirectContentBuilder build: @escaping () -> [C.Partial]) {
    self.init(dependency: dependency, build: build)
  }

  public convenience init<P: Publisher>(_ trigger: P, @ExpDirectContentBuilder build: @escaping () -> [C.Partial]) where P.Failure == Never {
    self.init(trigger: trigger, build: build)
  }
}

extension Dynamic where C == ExpSlottingContent {
  public convenience init<P: ReactiveProperty>(_ dependency: P, @ExpSlottingContentBuilder build: @escaping () -> [C.Partial]) {
    self.init(dependency: dependency, build: build)
  }

  public convenience init<P: Publisher>(_ trigger: P, @ExpSlottingContentBuilder build: @escaping () -> [C.Partial]) where P.Failure == Never {
    self.init(trigger: trigger, build: build)
  }
}