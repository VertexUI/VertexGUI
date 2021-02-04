extension Widget {
  internal func processMouseEvent(_ event: GUIMouseEvent) {
    switch event {
    case let event as GUIMouseEnterEvent:
      self._enablePseudoClass(Widget.PseudoClasses.hover)
    case let event as GUIMouseLeaveEvent:
      self._disablePseudoClass(Widget.PseudoClasses.hover)
    case let event as GUIMouseButtonClickEvent:
      self.onClick.invokeHandlers(event)
    default:
      break
    }
  }
}