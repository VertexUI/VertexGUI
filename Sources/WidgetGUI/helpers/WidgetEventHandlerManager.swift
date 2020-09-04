public class WidgetEventHandlerManager<Data> {
    
    public typealias Handler = (Data) -> Void

    public typealias UnregisterCallback = () -> Void

    public var handlers = [Int: Handler]()

    private var nextHandlerId = 0

    private let widget: Widget

    lazy public private(set) var chain = Chainer<Data>(widget, self)

    public init(_ widget: Widget) {

        self.widget = widget
    }

    public func callAsFunction(_ handler: @escaping Handler) -> UnregisterCallback {

        addHandler(handler)
    }

    // TODO: implement function to add to start of handler list
    public func addHandler(_ handler: @escaping Handler) -> UnregisterCallback {

        let currentHandlerId = nextHandlerId

        handlers[currentHandlerId] = handler

        nextHandlerId += 1

        return {

            self.handlers.removeValue(forKey: currentHandlerId)
        }
    }

    public func once(_ handler: @escaping Handler) {

        var unregisterCallback: UnregisterCallback? = nil

        let wrapperHandler = { (data: Data) in

            handler(data)

            if let unregister = unregisterCallback {

                unregister()
            }
        }

        unregisterCallback = addHandler(wrapperHandler)
    }
    
    public func invokeHandlers(_ data: Data) {

        // TODO: call handlers in same order as they were added

        for handler in handlers.values {

            handler(data)
        }
    }

    public func removeAllHandlers() {

        handlers.removeAll()
    }
}

extension WidgetEventHandlerManager {

    public struct Chainer<Data> {

        unowned private let chainValue: Widget

        unowned private let manager: WidgetEventHandlerManager<Data>

        public init(_ chainValue: Widget, _ manager: WidgetEventHandlerManager<Data>) {

            self.chainValue = chainValue

            self.manager = manager
        }

        public func callAsFunction(_ handler: @escaping WidgetEventHandlerManager<Data>.Handler) -> Widget {

            let unregisterCallback = manager.addHandler(handler)

            _ = chainValue.onDestroy(unregisterCallback)

            return chainValue
        }
    }
}