extension Widget {
  public enum LifecycleMethodInvocationAbortionReason {
    case layout(LayoutInvocationAbortionReason)
  }

  public enum LayoutInvocationAbortionReason {
    case layoutStillValid
  }
}