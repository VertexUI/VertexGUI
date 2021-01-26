import ExperimentalReactiveProperties

public class LifecycleView: Experimental.ComposedWidget {
  private var lifecycleMethodInvocationInfoBuffer: Bus<LifecycleMethodInvocationInfo>.MessageBuffer

  @ExperimentalReactiveProperties.MutableProperty
  private var invocationInfoItems: [LifecycleMethodInvocationInfo] = []

  public init(_ lifecycleMethodInvocationInfoBuffer: Bus<LifecycleMethodInvocationInfo>.MessageBuffer) {
    self.lifecycleMethodInvocationInfoBuffer = lifecycleMethodInvocationInfoBuffer
    super.init()
    _ = self.onDestroy(lifecycleMethodInvocationInfoBuffer.onMessageAdded { [unowned self] _ in
      print("UPDATE INVOCATION INFO ITEMS")
      invocationInfoItems = lifecycleMethodInvocationInfoBuffer.messages
    })
  }

  override public func performBuild() {
    rootChild = Experimental.SimpleColumn { [unowned self] in
      Experimental.Text(ExperimentalReactiveProperties.ComputedProperty(compute: {
        print("RECALC PROP")
        return String(invocationInfoItems.count)
      }, dependencies: [$invocationInfoItems]))

      Experimental.List($invocationInfoItems) { _ in
        Experimental.Text("WoW")
      }
    }
  }
}