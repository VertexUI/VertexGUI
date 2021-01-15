extension Widget {
  public func provideStyles(_ styles: [Experimental.Style]) {
    self.experimentalProvidedStyles.append(contentsOf: styles)
  }
}