extension Widget {
  @discardableResult public func onClick(_ handler: @escaping (GUIMouseButtonClickEvent) -> ()) -> Self {
    _ = onClickHandlerManager.addHandler(handler)
    return self
  }

  @discardableResult public func onClick(_ handler: @escaping () -> ()) -> Self {
    _ = onClickHandlerManager.addHandler({ _ in handler() })
    return self
  }

  @discardableResult public func onMouseDown(_ handler: @escaping (GUIMouseButtonDownEvent) -> ()) -> Self {
    _ = onMouseDownHandlerManager.addHandler(handler)
    return self
  }

  @discardableResult public func onMouseDown(_ handler: @escaping () -> ()) -> Self {
    _ = onMouseDownHandlerManager.addHandler({ _ in handler() })
    return self
  }

  @discardableResult public func onMouseUp(_ handler: @escaping (GUIMouseButtonUpEvent) -> ()) -> Self {
    _ = onMouseUpHandlerManager.addHandler(handler)
    return self
  }

  @discardableResult public func onMouseUp(_ handler: @escaping () -> ()) -> Self {
    _ = onMouseUpHandlerManager.addHandler({ _ in handler() })
    return self
  }

  @discardableResult public func onMouseEnter(_ handler: @escaping (GUIMouseEnterEvent) -> ()) -> Self {
    _ = onMouseEnterHandlerManager.addHandler(handler)
    return self
  }

  @discardableResult public func onMouseEnter(_ handler: @escaping () -> ()) -> Self {
    _ = onMouseEnterHandlerManager.addHandler({ _ in handler() })
    return self
  }

  @discardableResult public func onMouseMove(_ handler: @escaping (GUIMouseMoveEvent) -> ()) -> Self {
    _ = onMouseMoveHandlerManager.addHandler(handler)
    return self
  }

  @discardableResult public func onMouseMove(_ handler: @escaping () -> ()) -> Self {
    _ = onMouseMoveHandlerManager.addHandler({ _ in handler() })
    return self
  }

  @discardableResult public func onMouseWheel(_ handler: @escaping (GUIMouseWheelEvent) -> ()) -> Self {
    _ = onMouseWheelHandlerManager.addHandler(handler)
    return self
  }

  @discardableResult public func onMouseWheel(_ handler: @escaping () -> ()) -> Self {
    _ = onMouseWheelHandlerManager.addHandler({ _ in handler() })
    return self
  }

  @discardableResult public func onKeyDown(_ handler: @escaping (GUIKeyDownEvent) -> ()) -> Self {
    _ = onKeyDownHandlerManager.addHandler(handler)
    return self
  }

  @discardableResult public func onKeyDown(_ handler: @escaping () -> ()) -> Self {
    _ = onKeyDownHandlerManager.addHandler({ _ in handler() })
    return self
  }

  @discardableResult public func onKeyUp(_ handler: @escaping (GUIKeyUpEvent) -> ()) -> Self {
    _ = onKeyUpHandlerManager.addHandler(handler)
    return self
  }

  @discardableResult public func onKeyUp(_ handler: @escaping () -> ()) -> Self {
    _ = onKeyUpHandlerManager.addHandler({ _ in handler() })
    return self
  }

  @discardableResult public func onTextInput(_ handler: @escaping (GUITextInputEvent) -> ()) -> Self {
    _ = onTextInputHandlerManager.addHandler(handler)
    return self
  }

  @discardableResult public func onTextInput(_ handler: @escaping () -> ()) -> Self {
    _ = onTextInputHandlerManager.addHandler({ _ in handler() })
    return self
  }
}