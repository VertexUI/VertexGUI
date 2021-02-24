extension Widget {
  public enum LifecycleMethod: CaseIterable {
    case mount, build, updateChildren, updateBoxConfig, layout, resolveCumulatedValues, draw, unmount, destroy
  }
}