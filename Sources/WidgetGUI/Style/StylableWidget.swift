public protocol StylableWidget: Widget {
  /** Apply the given style to this Widget only. This function will overwrite the selector
  of the given style to only match itself. */
  func with(style: AnyStyle) -> Self
}

extension StylableWidget {
  public func with(style: AnyStyle) -> Self {
    styles.append(style)
    return self
  }
}