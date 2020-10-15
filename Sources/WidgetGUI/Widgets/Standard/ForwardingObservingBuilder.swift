public class ForwardingObservingBuilder<Value>: SingleChildWidget {
    private var observable: ObservableProperty<Value>

    private var childBuilder: (_ value: Value) -> Widget

    public init(observe observable: ObservableProperty<Value>, @WidgetBuilder child childBuilder: @escaping (_ value: Value) -> Widget) {
        self.observable = observable
        self.childBuilder = childBuilder
        super.init()
        _ = onDestroy(observable.onChanged { [unowned self] _ in
            invalidateChild()
        })
    }

    override open func buildChild() -> Widget {
        childBuilder(observable.value)
    }
}