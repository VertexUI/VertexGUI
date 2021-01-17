extension Widget {
  public func provideStyles(_ styles: [Experimental.Style]) -> Widget {
    self.experimentalProvidedStyles.append(contentsOf: styles)
    return self
  }
}