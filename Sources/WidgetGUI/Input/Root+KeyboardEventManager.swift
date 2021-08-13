extension Root {
	class KeyboardEventManager {
		unowned let root: Root

		init(root: Root) {
			self.root = root
		}

		func process(event rawEvent: RawKeyboardEvent) {
			var next = Optional(root.rootWidget)
			while let current = next {
				switch rawEvent {
				case let rawEvent as RawKeyDownEvent:
					current.processKeyboardEvent(GUIKeyDownEvent(
						key: rawEvent.key,
						keyStates: rawEvent.keyStates,
						repetition: rawEvent.repetition))
				case let rawEvent as RawKeyUpEvent:
					current.processKeyboardEvent(GUIKeyUpEvent(
						key: rawEvent.key,
						keyStates: rawEvent.keyStates,
						repetition: rawEvent.repetition))
				default:
					fatalError("unsupported RawKeyboardEvent: \(rawEvent)")
				}

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