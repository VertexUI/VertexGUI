public protocol EventfulObject: class {
  func removeAllEventHandlers()
}

extension EventfulObject {
  public func removeAllEventHandlers() {
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if let manager = child.value as? AnyEventHandlerManager {
        manager.removeAllHandlers()
      }
    }
  }
}
