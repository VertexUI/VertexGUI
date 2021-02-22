extension Widget {
  internal func processMouseEvent(_ event: GUIMouseEvent) {
    switch event {
    case let event as GUIMouseEnterEvent:
      self.enablePseudoClass(Widget.PseudoClasses.hover)

    case let event as GUIMouseMoveEvent:
      self.onMouseMoveHandlerManager.invokeHandlers(event)

    case let event as GUIMouseLeaveEvent:
      self.disablePseudoClass(Widget.PseudoClasses.hover)

    case let event as GUIMouseButtonDownEvent:
      self.onMouseDownHandlerManager.invokeHandlers(event)

    case let event as GUIMouseButtonUpEvent:
      self.onMouseUpHandlerManager.invokeHandlers(event)

    case let event as GUIMouseButtonClickEvent:
      self.onClickHandlerManager.invokeHandlers(event)

    case let event as GUIMouseWheelEvent:
      self.onMouseWheelHandlerManager.invokeHandlers(event)
    default:
      break
    }
  }
}