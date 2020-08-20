public protocol AnyStatefulWidget: Widget {
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