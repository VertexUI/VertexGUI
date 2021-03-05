extension Widget {
  public func invalidateMatchedStyles() {
    if !mounted {
      // print("warning: called invalidateMatchedStyles on widget that has not yet been mounted")
      return
    }
    context.queueLifecycleMethodInvocation(.updateMatchedStyles, target: self, sender: self, reason: .undefined)
  }
}