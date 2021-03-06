import CXShim

public final class FocusManager {
  var currentFocusedWidget: Widget? = nil
  var destroySubscription: AnyCancellable?

  public func requestFocus(on widget: Widget) {
    currentFocusedWidget?.internalFocused = false
    destroySubscription = nil
    currentFocusedWidget = widget
    destroySubscription = widget.$destroyed.sink { [unowned self] in
      if $0 {
        currentFocusedWidget = nil
        destroySubscription = nil
      }
    }
    widget.internalFocused = true
  }

  public func dropFocus(on widget: Widget) {
    if currentFocusedWidget === widget {
      currentFocusedWidget?.internalFocused = false
      currentFocusedWidget = nil
      destroySubscription = nil
    }
  }
}