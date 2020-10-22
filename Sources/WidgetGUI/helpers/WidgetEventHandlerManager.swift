internal protocol AnyWidgetEventHandlerManager {
  var widget: Widget? { get set }

  func removeAllHandlers()
}

public class WidgetEventHandlerManager<Data>: AnyWidgetEventHandlerManager {
  public typealias Handler = (Data) -> Void
  public typealias UnregisterCallback = () -> Void

  public var handlers = [Int: Handler]()
  private var nextHandlerId = 0
  internal var widget: Widget? = nil

  public init() {}

  public func callAsFunction(_ handler: @escaping Handler) -> UnregisterCallback {
    addHandler(handler)
  }

  public func chain(_ handler: @escaping Handler) -> Widget {
    _ = addHandler(handler)

    return widget!
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
