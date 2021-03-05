extension Widget {
  public enum LifecycleMethod: CaseIterable {
    case mount, build, updateChildren, updateMatchedStyles, resolveStyleProperties, layout, resolveCumulatedValues, draw, unmount, destroy
  }
}