import OpenCombine

public final class FocusManager {
  var currentFocusChain: [Widget] = []

  public func requestFocus(on widget: Widget) {
    let newChain = focusParentChain(leaf: widget)
    for index in 0..<currentFocusChain.count {
      if index >= newChain.count || currentFocusChain[index] !== newChain[index] {
        currentFocusChain[index].internalFocused = false
      }
    }
    currentFocusChain = newChain
  }

  public func dropFocus(on widget: Widget) {
    var unfocusChain = [Widget]()
    for (index, focusedWidget) in currentFocusChain.enumerated() {
      if focusedWidget === widget {
        unfocusChain = Array(currentFocusChain[index..<currentFocusChain.count])
        currentFocusChain = Array(currentFocusChain[0..<index])
        break
      }
    }
    for widget in unfocusChain {
      widget.internalFocused = false
    }
  }

  private func focusParentChain(leaf: Widget) -> [Widget] {
    var chain = [Widget]()
    var next = Optional(leaf)
    while let current = next {
      current.internalFocused = true
      next = current.parent as? Widget
      chain.append(current)
    }
    return chain.reversed()
  }
}