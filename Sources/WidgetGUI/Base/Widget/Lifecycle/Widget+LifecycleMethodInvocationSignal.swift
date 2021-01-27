import VisualAppBase

extension Widget {
  public enum LifecycleMethodInvocationSignal: Equatable {
    case started(method: LifecycleMethod, reason: LifecycleMethodInvocationReason, invocationId: Int, timestamp: Double)
    case aborted(method: LifecycleMethod, reason: LifecycleMethodInvocationAbortionReason, invocationId: Int, timestamp: Double)
    case completed(method: LifecycleMethod, invocationId: Int, timestamp: Double)

    public static func == (lhs: Self, rhs: Self) -> Bool {
      if case let .started(_, _, invocationId1, _) = lhs, case let .started(_, _, invocationId2, _) = rhs {
        return invocationId1 == invocationId2
      } else if case let .aborted(_, _, invocationId1, _) = lhs, case let .aborted(_, _, invocationId2, _) = rhs {
        return invocationId1 == invocationId2
      } else if case let .completed(_, invocationId1, _) = lhs, case let .completed(_, invocationId2, _) = rhs {
        return invocationId1 == invocationId2
      } else {
        return false
      }
    }
  }
}