extension Widget {
  internal func processMouseEvent(_ event: GUIMouseEvent) {
    switch event {
    case let event as GUIMouseEnterEvent:
      self.enablePseudoClass(Widget.PseudoClasses.hover)
      self.onMouseEnterHandlerManager.invokeHandlers(event)

    case let event as GUIMouseMoveEvent:
      self.onMouseMoveHandlerManager.invokeHandlers(event)

    case let event as GUIMouseLeaveEvent:
      self.disablePseudoClass(Widget.PseudoClasses.hover)
      self.onMouseLeaveHandlerManager.invokeHandlers(event)

    case let event as GUIMouseButtonDownEvent:
      self.enablePseudoClass(Widget.PseudoClasses.active)
      self.onMouseDownHandlerManager.invokeHandlers(event)

    case let event as GUIMouseButtonUpEvent:
      self.disablePseudoClass(Widget.PseudoClasses.active)
      self.onMouseUpHandlerManager.invokeHandlers(event)

    case let event as GUIMouseButtonClickEvent:
      self.onClickHandlerManager.invokeHandlers(event)

    case let event as GUIMouseWheelEvent:
      self.onMouseWheelHandlerManager.invokeHandlers(event)

    default:
      fatalError("not implemented event type \(event)")
    }
  }

  internal func processKeyboardEvent(_ event: GUIKeyboardEvent) {
    switch event {
    case let event as GUIKeyDownEvent:
      self.onKeyDownHandlerManager.invokeHandlers(event)

    case let event as GUIKeyUpEvent:
      self.onKeyUpHandlerManager.invokeHandlers(event)
    
    default:
      fatalError("not implemented event type \(event)")
    }
  }

  internal func processTextEvent(_ event: GUITextEvent) {
    switch event {
    case let event as GUITextInputEvent:
      self.onTextInputHandlerManager.invokeHandlers(event)

    default:
      fatalError("not implemented event type \(event)")
    }
  }
}