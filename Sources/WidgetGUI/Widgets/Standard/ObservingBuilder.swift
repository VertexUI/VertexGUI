import GfxMath

public class ObservingBuilder: SingleChildWidget {
  private var observables: [AnyObservableProperty]
  private var childBuilder: () -> Widget
    
  private var anyObservableChanged: Bool = false

  public init(
    _ observables: [AnyObservableProtocol], @WidgetBuilder child childBuilder: @escaping () -> Widget
  ) {
    self.observables = observables.map { $0.any }
    self.childBuilder = childBuilder

    super.init()

    for observable in self.observables {
      _ = onDestroy(observable.onChanged { [unowned self] _ in
        anyObservableChanged = true
      })
    }
    
    _ = self.onTick { [unowned self] _ in
      if anyObservableChanged {
        invalidateChild()
        anyObservableChanged = false
      }
    }
  }


  public convenience init(
    _ observables: AnyObservableProtocol...,
    @WidgetBuilder child childBuilder: @escaping () -> Widget
  ) {
    self.init(observables, child: childBuilder)
  }

  override open func buildChild() -> Widget {
    childBuilder()
  }
}
