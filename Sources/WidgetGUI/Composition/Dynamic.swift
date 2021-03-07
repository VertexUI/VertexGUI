import Events
import CXShim

public class Dynamic<C: ExpContentProtocol> {
  var associatedStyleScope: UInt

  let content: C

  var triggerSubscription: AnyCancellable?

  private init<P: Publisher>(trigger: P, build: @escaping () -> [C.Partial]) where P.Failure == Never {
    self.associatedStyleScope = Widget.activeStyleScope

    let partials = build()
    self.content = C(partials: partials)
    
    triggerSubscription = trigger.sink { [unowned self] _ in
      Widget.inStyleScope(self.associatedStyleScope) {
        self.content.partials = build()
      }
    }
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