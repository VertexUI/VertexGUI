extension Widget {
  public func with(classes: [String]? = nil) -> Self {
    if let classes = classes {
      self.classes.append(contentsOf: classes)
    }
    return self
  }
}