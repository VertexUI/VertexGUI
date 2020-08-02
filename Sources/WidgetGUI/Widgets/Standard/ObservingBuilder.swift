public class ObservingBuilder: SingleChildWidget {
    private var observables: [AnyObservable]

    private var childBuilder: () -> Widget

    public init(_ observables: [AnyObservable], @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        self.observables = observables
        self.childBuilder = childBuilder
        super.init()
        for observable in observables {
            autoClean(observable.onChanged { [unowned self] _ in
                invalidateChild()
            })
        }
    }

    override open func buildChild() -> Widget {
        childBuilder()
    }
}