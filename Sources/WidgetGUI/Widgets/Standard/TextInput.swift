import CustomGraphicsMath
import VisualAppBase

public class TextInput: Widget, GUIMouseEventConsumer, GUIKeyEventConsumer, GUITextEventConsumer {
    public internal(set) var text: String

    private var carretPosition: Int = 0

    lazy private var textWidget = Text(text)

    public internal(set) var onTextChanged = EventHandlerManager<String>()

    private var dropCursorRequest: (() -> ())?

    public init(_ initialText: String = "") {
        self.text = initialText
        super.init()
        self.focusable = true
    }

    override public func build() {
        textWidget.text = text
        children = [textWidget]
    }

    override public func performLayout() {
        textWidget.constraints = BoxConstraints(
            minSize: constraints!.constrain(DSize2(50, constraints!.minHeight)),
            maxSize: constraints!.maxSize)
        textWidget.layout()
        bounds.size = textWidget.bounds.size
    }

    private func syncText() {
        textWidget.text = text
        onTextChanged.invokeHandlers(text)
    }

    public func consume(_ event: GUIMouseEvent) {
        if event is GUIMouseButtonClickEvent {
            requestFocus()
            if focused {
                invalidateRenderState()
            }
        } else if event is GUIMouseEnterEvent {
            dropCursorRequest = context!.requestCursor(.Text)
        } else if event is GUIMouseLeaveEvent {
            if let drop = dropCursorRequest {
                drop()
            }
        }
    }

    public func consume(_ event: GUIKeyEvent) {
        if let event = event as? GUIKeyDownEvent {
            switch event.key {
            case .Backspace:
                if carretPosition > 0 && text.count >= carretPosition {
                    invalidateRenderState {
                        text.remove(at: text.index(text.startIndex, offsetBy: carretPosition - 1))
                        carretPosition -= 1
                        syncText()
                    }
                }
            case .Delete:
                if carretPosition < text.count {
                    invalidateRenderState {
                        text.remove(at: text.index(text.startIndex, offsetBy: carretPosition))
                        syncText()
                    }
                }
            default:
                break
            }
        }
    }

    public func consume(_ event: GUITextEvent) {
        if let event = event as? GUITextInputEvent {
            invalidateRenderState {
                text.insert(contentsOf: event.text, at: text.index(text.startIndex, offsetBy: carretPosition))
                carretPosition += event.text.count
                syncText()
            }
        }
    }

    override public func renderContent() -> RenderObject? {
        let preCarretBounds = textWidget.getSubBounds(to: carretPosition)
        let carretSize = DSize2(5, globalBounds.size.height)
        let carretBounds = DRect(min: globalBounds.min + DVec2(preCarretBounds.max.x, 0), size: carretSize)

        return RenderObject.Container {
            RenderObject.RenderStyle(fillColor: FixedRenderValue(.Blue)) {
                RenderObject.Rectangle(carretBounds)
            }

            textWidget.render()
        }
    }

    override public func destroySelf() {
        onTextChanged.removeAllHandlers()
        if let drop = dropCursorRequest {
            drop()
        }
    }
}