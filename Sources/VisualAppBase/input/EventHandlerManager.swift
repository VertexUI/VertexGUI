public protocol AnyEventHandlerManager {
  func removeAllHandlers()
}

public class EventHandlerManager<Data>: AnyEventHandlerManager {
  public typealias Handler = (Data) -> Void
  public typealias UnregisterCallback = () -> Void
  public var handlers = [Int: Handler]()
  private var nextHandlerId = 0

  public init() {
  }

  deinit {
    removeAllHandlers()
  }

  public func callAsFunction(_ handler: @escaping Handler) -> UnregisterCallback {
    addHandler(handler)
  }

  // TODO: implement function to add to start of handler list
  @discardableResult
  public func addHandler(_ handler: @escaping Handler) -> UnregisterCallback {
    let currentHandlerId = nextHandlerId
    handlers[currentHandlerId] = handler
    nextHandlerId += 1
    return {
      self.handlers.removeValue(forKey: currentHandlerId)
    }
  }

  public func once(_ handler: @escaping Handler) -> UnregisterCallback {
    var unregisterCallback: UnregisterCallback? = nil

    let wrapperHandler = { (data: Data) in
      handler(data)
      if let unregister = unregisterCallback {
        unregister()
      }
    }

    unregisterCallback = addHandler(wrapperHandler)

    return unregisterCallback!
  }

  public func invokeHandlers(_ getData: @autoclosure () -> Data) {
    // TODO: call handlers in same order as they were added
    if handlers.count > 0 {
      let data = getData()
      for handler in handlers.values {
        handler(data)
      }
    }
  }

  public func removeAllHandlers() {
    handlers.removeAll()
  }
}

//@available(*, deprecated, message: "Just use EventHandlerManager (probably)!")
public class ThrowingEventHandlerManager<Data>: AnyEventHandlerManager {
  public typealias Handler = (Data) throws -> Void
  public typealias UnregisterCallback = () -> Void
  public var handlers = [Int: Handler]()
  private var nextHandlerId = 0

  public init() {
  }

  public func callAsFunction(_ handler: @escaping Handler) -> UnregisterCallback {
    addHandler(handler)
  }

  public func addHandler(_ handler: @escaping Handler) -> UnregisterCallback {
    let currentHandlerId = nextHandlerId
    handlers[currentHandlerId] = handler
    nextHandlerId += 1
    return {
      self.handlers.removeValue(forKey: currentHandlerId)
    }
  }

  public func invokeHandlers(_ data: Data) throws {
    for handler in handlers.values {
      try handler(data)
    }
  }

  public func removeAllHandlers() {
    handlers.removeAll()
  }
}
