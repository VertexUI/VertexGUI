extension Widget {
  public func invalidateMatchedStyles() {
    lifecycleBus.publish(WidgetLifecycleMessage(sender: self, content: .MatchedStylesInvalidated))
  }
}