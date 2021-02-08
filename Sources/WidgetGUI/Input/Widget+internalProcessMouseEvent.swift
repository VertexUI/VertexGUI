extension Widget {
  internal func processMouseEvent(_ event: GUIMouseEvent) {
    switch event {
    case let event as GUIMouseEnterEvent:
      self._enablePseudoClass(Widget.PseudoClasses.hover)
    case let event as GUIMouseMoveEvent:
      self.onMouseMove.invokeHandlers(event)
    case let event as GUIMouseLeaveEvent:
      self._disablePseudoClass(Widget.PseudoClasses.hover)
    case let event as GUIMouseButtonDownEvent:
      self.onMouseDown.invokeHandlers(event)
    case let event as GUIMouseButtonUpEvent:
      self.onMouseUp.invokeHandlers(event)
    case let event as GUIMouseButtonClickEvent:
      self.onClick.invokeHandlers(event)
    case let event as GUIMouseWheelEvent:
      self.onMouseWheel.invokeHandlers(event)
    default:
      break
    }
  }
}