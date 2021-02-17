extension Widget {
  public func provideStyles(_ styles: [Style]) -> Widget {
    self.providedStyles.append(contentsOf: styles)
    return self
  }
}