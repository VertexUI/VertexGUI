extension Widget {
  public struct DebugMessage: Equatable {
    public var message: String

    public init(_ message: String) {
      self.message = message
    }
  }
}