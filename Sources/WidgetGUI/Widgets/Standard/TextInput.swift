import CustomGraphicsMath
import VisualAppBase

public class TextInput: Widget, GUIMouseEventConsumer, GUIKeyEventConsumer, GUITextEventConsumer {
    public internal(set) var text: String {
        didSet {
            onTextChanged.invokeHandlers(text)
            textWidget.text = text
            invalidateRenderState()
        }
    }

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
        children = [textWidget]
    }

    override public func performLayout() {
        textWidget.constraints = BoxConstraints(
            minSize: constraints!.constrain(DSize2(50, constraints!.minHeight)),
            maxSize: constraints!.maxSize)
        textWidget.layout()
        bounds.size = textWidget.bounds.size
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
                    text.remove(at: text.index(text.startIndex, offsetBy: carretPosition - 1))
                    carretPosition -= 1
                }
            case .Delete:
                if carretPosition < text.count {
                    text.remove(at: text.index(text.startIndex, offsetBy: carretPosition))
                }
            default:
                break
            }
        }
    }

    public func consume(_ event: GUITextEvent) {
        if let event = event as? GUITextInputEvent {
            text.insert(contentsOf: event.text, at: text.index(text.startIndex, offsetBy: carretPosition))
            carretPosition += event.text.count
        }
    }

    override public func renderContent() -> RenderObject? {
        let color: Color = focused ? Color.Yellow : Color.Red
        
        return RenderObject.RenderStyle(fillColor: FixedRenderValue(color)) {
            RenderObject.Rectangle(globalBounds)

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