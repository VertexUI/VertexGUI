extension Widget {
  public func with(classes: [String]) -> Self {
    self.classes.append(contentsOf: classes)
    return self
  }
}