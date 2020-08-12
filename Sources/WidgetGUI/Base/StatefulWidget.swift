public protocol StatefulWidgetMarker {}

public protocol AnyStatefulWidget: class {
    var anyState: Any? { get set }
}

public protocol StatefulWidget: AnyStatefulWidget {
    associatedtype State: Any

    var state: State { get set }
}

public extension StatefulWidget {
    var anyState: Any? {
        get {
            return state
        }
        set {
            // TODO: what if internal state is not optional, can't set it to nil???
            if let newState = newValue as? State {
                state = newState
            } else {
                fatalError("Tried to set unsupported type of state on StatefulWidget.")
            }
        }
    }
}


/*
public class AnyStatefulWidget: StatefulWidget {
    public typealias State = Any

    private var getState: () -> State?
    private var setState: (_ newValue: State?) -> Void

    public var state: State? {
        get {
            return getState()
        }
        set {
            setState(newValue)
        }
    }

    public init?(_ widget: Widget) {
        if widget is StatefulWidgetMarker {
            
            getState = {
                convert(widget as! Widget & StatefulWidgetMarker).state //(widget as! StatefulWidget).state
            }
            setState = {
                widget.state = $0
            }
        } else {
            return nil
        }
    }
}

func convert<T: Widget>(_ widget: T) -> some StatefulWidget where T: StatefulWidgetMarker {
    return widget
}*/