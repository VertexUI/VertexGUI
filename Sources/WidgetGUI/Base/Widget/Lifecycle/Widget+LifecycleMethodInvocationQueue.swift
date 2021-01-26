import VisualAppBase

extension Widget {
  public class LifecycleMethodInvocationQueue {
    private var entries: [Entry] = []

    public init() {}

    public func queue(_ entry: Entry) {
      entries.append(entry)
    }

    public class Entry {
      public var method: LifecycleMethod
      public var target: Widget
      public var sender: Widget
      public var reason: LifecycleMethodInvocationReason
      public var tick: Tick

      public init(method: LifecycleMethod, target: Widget, sender: Widget, reason: LifecycleMethodInvocationReason, tick: Tick) {
        self.method = method
        self.target = target
        self.sender = sender
        self.reason = reason
        self.tick = tick
      }
    }
  }
}