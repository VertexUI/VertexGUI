import CustomGraphicsMath
import VisualAppBase

public class TextInput: Widget, GUIMouseEventConsumer, GUIKeyEventConsumer, GUITextEventConsumer {
    public internal(set) var text: String {
        didSet {
            onTextChanged.invokeHandlers(text)
            textWidget.text = text
        }
    }

    public internal(set) var onTextChanged = EventHandlerManager<String>()

    lazy private var textWidget = Text(text)

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
        }
    }

    public func consume(_ event: GUIKeyEvent) {
        if let event = event as? GUIKeyUpEvent {
        }
    }

    public func consume(_ event: GUITextEvent) {
        if let event = event as? GUITextInputEvent {
            text += event.text
            invalidateRenderState()
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
    }
}