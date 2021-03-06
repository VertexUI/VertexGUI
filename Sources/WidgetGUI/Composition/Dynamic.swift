import Events
import CXShim

public class Dynamic<C: ExpContentProtocol> {
  var associatedStyleScope: UInt

  let content: C

  let onDependenciesChanged = EventHandlerManager<Void>()

  var triggerSubscription: AnyCancellable?

  private init<P: Publisher>(trigger: P, build: @escaping () -> [C.Partial]) where P.Failure == Never {
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
  public convenience init<P: Publisher>(_ trigger: P, @ExpDirectContentBuilder build: @escaping () -> [C.Partial]) where P.Failure == Never {
    self.init(trigger: trigger, build: build)
  }
}

extension Dynamic where C == ExpSlottingContent {
  public convenience init<P: Publisher>(_ trigger: P, @ExpSlottingContentBuilder build: @escaping () -> [C.Partial]) where P.Failure == Never {
    self.init(trigger: trigger, build: build)
  }
}