extension Widget {
  public enum LifecycleMethod: CaseIterable {
    case mount, build, updateChildren, updateBoxConfig, layout, resolveCumulatedValues, render, unmount, destroy
  }
}