extension Widget {
  public struct LifecycleMethodInvocationSignalGroup: Equatable {
    public var method: LifecycleMethod
    public var invocationId: Int
    public var signals: [LifecycleMethodInvocationSignal]
    public var startTimestamp: Double {
      for signal in signals {
        switch signal {
        case let .started(_, _, _, timestamp):
          return timestamp
        default:
          break
        }
      }
      return -1
    }
  }
}