import VisualAppBase

extension Widget {
  public enum LifecycleMethodInvocationInfo {
    case started(method: LifecycleMethod, reason: LifecycleMethodInvocationReason, invocationId: Int, tick: Tick)
    case ended(method: LifecycleMethod, invocationId: Int, tick: Tick)
  }
}