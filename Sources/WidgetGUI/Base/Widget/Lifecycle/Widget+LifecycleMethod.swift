extension Widget {
  public enum LifecycleMethod: CaseIterable {
    case build, mount, layout, resolveCumulatedValues, render, unmount, destroy
  }
}