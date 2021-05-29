extension Root {
  class TextInputEventManager {
    unowned let root: Root

    init(root: Root) {
      self.root = root
    }

    func process(event: RawTextInputEvent) {
      var next = Optional(root.rootWidget)
      while let current = next {
        current.processTextEvent(GUITextInputEvent(event.text))

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
}