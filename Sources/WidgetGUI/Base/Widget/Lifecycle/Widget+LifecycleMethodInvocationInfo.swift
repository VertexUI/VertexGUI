import VisualAppBase

extension Widget {
  public enum LifecycleMethodInvocationInfo: Equatable {
    case started(method: LifecycleMethod, reason: LifecycleMethodInvocationReason, invocationId: Int, timestamp: Double)
    case ended(method: LifecycleMethod, invocationId: Int, timestamp: Double)

    public static func == (lhs: Self, rhs: Self) -> Bool {
      if case let .started(_, _, invocationId1, _) = lhs, case let .started(_, _, invocationId2, _) = rhs {
        return invocationId1 == invocationId2
      } else if case let .ended(_, invocationId1, _) = lhs, case let .ended(_, invocationId2, _) = rhs {
        return invocationId1 == invocationId2
      } else {
        return false
      }
    }
  }
}