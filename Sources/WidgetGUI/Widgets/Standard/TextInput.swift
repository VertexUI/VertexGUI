import Foundation
import CustomGraphicsMath
import VisualAppBase

public class TextInput: Widget, StatefulWidget, GUIMouseEventConsumer, GUIKeyEventConsumer, GUITextEventConsumer {
    public struct Config {
        public var textConfig: Text.Config
        public var caretColor: Color
        
        public init(textConfig: Text.Config, caretColor: Color) {
            self.textConfig = textConfig
            self.caretColor = caretColor
        }

        public init(partial partialConfig: PartialConfig?, default defaultConfig: Config) {
            self.textConfig = Text.Config(partial: partialConfig?.textConfig, default: defaultConfig.textConfig)
            self.caretColor = partialConfig?.caretColor ?? defaultConfig.caretColor
        }
    }

    public struct PartialConfig {
        public var textConfig: Text.PartialConfig?
        public var caretColor: Color?

        public init(textConfig: Text.PartialConfig? = nil, caretColor: Color? = nil) {
            self.textConfig = textConfig
            self.caretColor = caretColor
        }

        public init(partials: [PartialConfig]) {
            var textConfigs = [Text.PartialConfig]()

            for partial in partials {
                self.caretColor = partial.caretColor ?? self.caretColor
                
                if let partial = partial.textConfig {
                    textConfigs.append(partial)
                }
            }

            self.textConfig = Text.PartialConfig(partials: textConfigs)
        }
    }

    public static let defaultConfig = Config(textConfig: Text.defaultConfig, caretColor: Color(120, 255, 180, 255))
    
    public struct State {
        public var caretBlinkStartTimestamp: Double = Date.timeIntervalSinceReferenceDate
    }

    private var config: Config

    public var state = State()
    
    public internal(set) var text: String

    private var caretPosition: Int = 0

    lazy private var textWidget = Text(text)

    public internal(set) var onTextChanged = EventHandlerManager<String>()

    private var dropCursorRequest: (() -> ())?

    public init(_ initialText: String = "", config: Config = TextInput.defaultConfig) {
        self.text = initialText
        self.config = config //!= nil ? Config(partials: [config!], default: Self.defaultConfig) : Self.defaultConfig
        super.init()
        self.focusable = true
    }

    public convenience init(_ initialText: String = "", caretColor: Color) {
        self.init(initialText, config: Config(textConfig: Self.defaultConfig.textConfig, caretColor: caretColor))
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
                if caretPosition > 0 && text.count >= caretPosition {
                    invalidateRenderState {
                        text.remove(at: text.index(text.startIndex, offsetBy: caretPosition - 1))
                        caretPosition -= 1
                        syncText()
                    }
                }
            case .Delete:
                if caretPosition < text.count {
                    invalidateRenderState {
                        text.remove(at: text.index(text.startIndex, offsetBy: caretPosition))
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
                text.insert(contentsOf: event.text, at: text.index(text.startIndex, offsetBy: caretPosition))
                caretPosition += event.text.count
                syncText()
            }
        }
    }

    override public func renderContent() -> RenderObject? {
        let preCaretBounds = textWidget.getSubBounds(to: caretPosition)
        let caretSize = DSize2(5, globalBounds.size.height)
        let caretBounds = DRect(min: globalBounds.min + DVec2(preCaretBounds.max.x, 0), size: caretSize)

        return RenderObject.Container { [unowned self] in
            if focused {
                RenderObject.RenderStyle(
                    fillColor: TimedRenderValue(
                        id: 0, 
                        startTimestamp: state.caretBlinkStartTimestamp, 
                        duration: 1, 
                        repetitions: 0) {
                            config.caretColor.adjusted(alpha: $0 > 0.5 ? 255 : 0) 
                    }) {
                        RenderObject.Rectangle(caretBounds)
                    }
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