public extension Widget {
  /**
  Add styles to be applied to this Widget or any of it's direct and indirect children if the
  selector matches.
  */
  public func provideStyles(@StyleBuilder buildStyles: () -> [AnyStyle]) -> Widget {
    styles.append(contentsOf: buildStyles())
    return self
  }
}