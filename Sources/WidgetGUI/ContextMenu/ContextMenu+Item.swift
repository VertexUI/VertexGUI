extension ContextMenu {
  public struct Item {
    public var title: String
    public var action: () -> ()

    public init(title: String, action: @escaping () -> ()) {
      self.title = title
      self.action = action
    }
  }
}