public class ForwardingObservingBuilder<Value>: SingleChildWidget {
    private var observable: Observable<Value>

    private var childBuilder: (_ value: Value) -> Widget

    public init(observe observable: Observable<Value>, @WidgetBuilder child childBuilder: @escaping (_ value: Value) -> Widget) {
        self.observable = observable
        self.childBuilder = childBuilder
        super.init()
        autoClean(observable.onChanged { [unowned self] _ in
            invalidateChild()
        })
    }

    override open func buildChild() -> Widget {
        childBuilder(observable.value)
    }
}