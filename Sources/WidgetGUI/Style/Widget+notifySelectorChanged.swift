extension Widget {
  public func notifySelectorChanged() {
    lifecycleBus.publish(WidgetLifecycleMessage(sender: self, content: .SelectorChanged))
  }
}