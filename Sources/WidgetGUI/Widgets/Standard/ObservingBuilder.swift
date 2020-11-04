import CustomGraphicsMath

public class ObservingBuilder: SingleChildWidget {
  private var observables: [AnyObservableProperty]
  private var childBuilder: () -> Widget
    
  private var anyObservableChanged: Bool = false

  public init(
    _ observables: [AnyObservableProperty], @WidgetBuilder child childBuilder: @escaping () -> Widget
  ) {
    self.observables = observables
    self.childBuilder = childBuilder

    super.init()

    for observable in observables {
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

  public convenience init<Value>(
    _ observable: ObservableProperty<Value>, @WidgetBuilder child childBuilder: @escaping () -> Widget
  ) {
    self.init([observable.any], child: childBuilder)
  }

  public convenience init<Value1, Value2>(
    _ observable1: ObservableProperty<Value1>, _ observable2: ObservableProperty<Value2>,
    @WidgetBuilder child childBuilder: @escaping () -> Widget
  ) {
    self.init([observable1.any, observable2.any], child: childBuilder)
  }

  override open func buildChild() -> Widget {
    childBuilder()
  }
}
