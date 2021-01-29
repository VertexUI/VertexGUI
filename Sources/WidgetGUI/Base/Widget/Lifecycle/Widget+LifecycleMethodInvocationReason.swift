extension Widget {
  public enum LifecycleMethodInvocationReason {
    case build(BuildInvocationReason)
    case mount(MountInvocationReason)
    case layout(LayoutInvocationReason)
    case render(RenderInvocationReason)
    case unmount(UnmountInvocationReason)
    case destroy(DestroyInvocationReason)
    case queued(LifecycleMethodInvocationQueue.Entry)
    case undefined
  }

  public enum BuildInvocationReason {
    case parentBuilds
  }

  public enum MountInvocationReason {
  }

  public enum LayoutInvocationReason {
    case parentLayouts
  }

  public enum RenderInvocationReason {
    case renderRoot
    case parentRenders
    case renderContentOfParent(Widget)
  }

  public enum UpdateRenderStateInvocationReason {
    case renderCalled(RenderInvocationReason)
    case rootTick
  }

  public enum UnmountInvocationReason {
  }

  public enum DestroyInvocationReason {
    case parentDestroyed
  }
}