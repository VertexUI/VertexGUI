import CXShim

public final class FocusManager {
  var currentFocusedWidget: Widget? = nil
  var destroySubscription: AnyCancellable?

  public func requestFocus(on widget: Widget) {
    if let previousFocusedWidget = currentFocusedWidget {
      currentFocusedWidget?.internalFocused = false
      unfocusParentChain(leaf: previousFocusedWidget)
    }
    destroySubscription = nil

    currentFocusedWidget = widget
    destroySubscription = widget.$destroyed.sink { [unowned self] in
      if $0 {
        currentFocusedWidget = nil
        destroySubscription = nil
      }
    }
    focusParentChain(leaf: widget)
  }

  public func dropFocus(on widget: Widget) {
    if currentFocusedWidget === widget {
      unfocusChildrenChain(parent: widget)
      currentFocusedWidget = nil
      destroySubscription = nil
    }
  }

  private func focusParentChain(leaf: Widget) {
    var next = Optional(leaf)
    while let current = next {
      current.internalFocused = true
      next = current.parent as? Widget
    }
  }

  private func unfocusParentChain(leaf: Widget) {
    var next = Optional(leaf)
    while let current = next {
      current.internalFocused = false
      next = current.parent as? Widget
    }
  }

  private func unfocusChildrenChain(parent: Widget) {
    var next = Optional(parent)
    while let current = next {
      current.internalFocused = false
      next = nil
      for child in current.children {
        if child.focused {
          next = child
          break
        }
      }
    }
  }
}