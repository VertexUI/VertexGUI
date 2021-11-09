extension Widget {
  public struct DebugMessage {
    public var message: String
    public var sender: Widget

    public init(_ message: String, sender: Widget) {
      self.message = message
      self.sender = sender
    }
  }
}