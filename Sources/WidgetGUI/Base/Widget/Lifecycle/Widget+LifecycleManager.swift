import Events
import VisualAppBase

extension Widget {
  public class LifecycleManager {
    private let getCurrentTick: () -> Tick

    var queues: [LifecycleMethod: LifecycleMethodInvocationQueue] = LifecycleMethod.allCases.reduce(into: [:]) {
      $0[$1] = LifecycleMethodInvocationQueue()
    }

    public init(_ getCurrentTick: @escaping () -> Tick) {
      self.getCurrentTick = getCurrentTick
    }

    public func queue(_ method: LifecycleMethod, target: Widget, sender: Widget, reason: LifecycleMethodInvocationReason) {
      let newEntry = LifecycleMethodInvocationQueue.Entry(method: method, target: target, sender: sender, reason: reason, tick: getCurrentTick())
      queues[method]!.queue(newEntry)
    }
  }
}