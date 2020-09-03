import CustomGraphicsMath

public class ObservingBuilder: SingleChildWidget {

    private var observables: [AnyObservable]

    private var childBuilder: () -> Widget

    public init(_ observables: [AnyObservable], @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.observables = observables

        self.childBuilder = childBuilder

        super.init()

        for observable in observables {

            _ = onDestroy(observable.onChanged { [unowned self] _ in

                invalidateChild()
            })
        }
    }

    public convenience init(_ observables: AnyObservable..., @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.init(observables, child: childBuilder)
    }

    override open func buildChild() -> Widget {

        childBuilder()
    }
}