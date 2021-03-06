extension Widget {
  @discardableResult
  public static func inStyleScope<T>(_ scope: UInt, block: () -> T) -> T {
    let previousActiveStyleScope = Widget.activeStyleScope
    Widget.activeStyleScope = scope
    defer { Widget.activeStyleScope = previousActiveStyleScope }
    return block()
  }
}