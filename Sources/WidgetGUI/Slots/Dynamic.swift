import ReactiveProperties

public class Dynamic {
  var associatedStyleScope: UInt

  public init<P: ReactiveProperty>(_ dependency: P) {
    self.associatedStyleScope = Widget.activeStyleScope
  }

  public func callAsFunction(@ExpDirectContentBuilder build: () -> ExpDirectContent) -> ExpDirectContent {
    /*let partials = buildPartials()   
    let content = ExpDirectContent(partials: partials)
    onUpdateDynamic {// or whatever
      Widget.inStyleScope(associatedStyleScope) {
        content.partials = buildPartials()
      }
    }*/
    build()
  }

  public func callAsFunction(@ExpSlottingContentBuilder build: () -> ExpSlottingContent) -> ExpSlottingContent {
    build()
  }
}