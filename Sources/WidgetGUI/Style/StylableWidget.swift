public protocol StylableWidget: Widget {
  /**
  - Returns: `true` if the Widget can handle and apply the given type of StyleProperties. `false` if not.
  */
  func acceptsStyleProperties(_ properties: AnyStyleProperties) -> Bool

  func acceptsStyle(_ style: AnyStyle) -> Bool
}

extension StylableWidget {
  public func acceptsStyle(_ style: AnyStyle) -> Bool {
    acceptsStyleProperties(style.anyProperties)
  }
}