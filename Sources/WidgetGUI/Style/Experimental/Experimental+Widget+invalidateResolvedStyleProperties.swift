extension Widget {
  public func invalidateResolvedStyleProperties() {
    if !mounted {
      //print("warning: called invalidateResolvedStyleProperties() on a widget that has not yet been mounted")
      return
    }

    context.queueLifecycleMethodInvocation(.resolveStyleProperties, target: self, sender: self, reason: .undefined)
  }
}