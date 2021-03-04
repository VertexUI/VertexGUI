extension Widget {
  public func onClick(_ handler: @escaping (GUIMouseButtonClickEvent) -> ()) -> Self {
    _ = onClickHandlerManager.addHandler(handler)
    return self
  }

  public func onClick(_ handler: @escaping () -> ()) -> Self {
    _ = onClickHandlerManager.addHandler({ _ in handler() })
    return self
  }

  public func onMouseDown(_ handler: @escaping (GUIMouseButtonDownEvent) -> ()) -> Self {
    _ = onMouseDownHandlerManager.addHandler(handler)
    return self
  }

  public func onMouseDown(_ handler: @escaping () -> ()) -> Self {
    _ = onMouseDownHandlerManager.addHandler({ _ in handler() })
    return self
  }

  public func onMouseUp(_ handler: @escaping (GUIMouseButtonUpEvent) -> ()) -> Self {
    _ = onMouseUpHandlerManager.addHandler(handler)
    return self
  }

  public func onMouseUp(_ handler: @escaping () -> ()) -> Self {
    _ = onMouseUpHandlerManager.addHandler({ _ in handler() })
    return self
  }

  public func onMouseMove(_ handler: @escaping (GUIMouseMoveEvent) -> ()) -> Self {
    _ = onMouseMoveHandlerManager.addHandler(handler)
    return self
  }

  public func onMouseMove(_ handler: @escaping () -> ()) -> Self {
    _ = onMouseMoveHandlerManager.addHandler({ _ in handler() })
    return self
  }

  public func onMouseWheel(_ handler: @escaping (GUIMouseWheelEvent) -> ()) -> Self {
    _ = onMouseWheelHandlerManager.addHandler(handler)
    return self
  }

  public func onMouseWheel(_ handler: @escaping () -> ()) -> Self {
    _ = onMouseWheelHandlerManager.addHandler({ _ in handler() })
    return self
  }

  public func onKey(_ handler: @escaping (GUIKeyEvent) -> ()) -> Self {
    _ = onKeyHandlerManager.addHandler(handler)
    return self
  }

  public func onKey(_ handler: @escaping () -> ()) -> Self {
    _ = onKeyHandlerManager.addHandler({ _ in handler() })
    return self
  }
}