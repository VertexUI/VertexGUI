extension Widget {
  /// automatically recurses to all children
  public func invalidateRootSizeDependentThings() {
    for child in children {
      child.invalidateRootSizeDependentThings()
    }

    updateExplicitConstraints()
  }
}