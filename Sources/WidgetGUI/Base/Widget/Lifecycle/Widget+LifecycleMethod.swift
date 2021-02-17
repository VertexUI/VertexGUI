extension Widget {
  public enum LifecycleMethod: CaseIterable {
    case mount, build, updateChildren, layout, resolveCumulatedValues, render, unmount, destroy
  }
}