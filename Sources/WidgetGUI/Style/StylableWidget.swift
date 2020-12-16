public protocol StylableWidget: Widget {
  func with(style: AnyStyle) -> Self
}

extension StylableWidget {
  public func with(style: AnyStyle) -> Self {
    styles.append(style)
    return self
  }
}