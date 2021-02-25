extension Widget {
  public enum LifecycleMethod: CaseIterable {
    case mount, build, updateChildren, layout, resolveCumulatedValues, draw, unmount, destroy
  }
}