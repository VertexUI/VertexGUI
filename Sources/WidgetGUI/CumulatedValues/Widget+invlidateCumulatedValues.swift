extension Widget {
  public func invalidateCumulatedValues() {
    if !mounted || destroyed {
      //print("warning: called invalidateCumulatedValues() on a widget that has not yet been mounted or was already destroyed")
      return
    }

    context.queueLifecycleMethodInvocation(.resolveCumulatedValues, target: self, sender: self, reason: .undefined)
  }
}