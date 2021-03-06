public protocol FocusableWidget: Widget {
}

extension FocusableWidget {
  public func requestFocus() {
    if !mounted || destroyed {
      //print("warning: called requestFocus() on a widget that has not yet been mounted or was already destroyed")
    } else {
      context.focusManager.requestFocus(on: self)
    }
  }

  public func dropFocus() {
    if !mounted || destroyed {
      //print("warning: called dropFocus() on a widget that has not yet been mounted or was already destroyed")
    } else {
      context.focusManager.dropFocus(on: self)
    }
  }
}

extension Widget: FocusableWidget {}