import Foundation
import CustomGraphicsMath
import VisualAppBase

public enum ButtonState {
    case Normal, Hover
}

public struct ButtonStyle {
    var background: Color
    var cursor: Cursor
}

public let defaultButtonTextConfig = Text.PartialConfig(
    fontConfig: PartialFontConfig(
        family: defaultFontFamily, size: 16, weight: .Bold, style: .Normal),
    transform: .Uppercase,
    color: .Black,
    wrap: false)

public let defaultButtonStyles: [ButtonState: ButtonStyle] = [
    .Normal: ButtonStyle(background: Color(255, 0, 0, 255), cursor: .Arrow),
    .Hover: ButtonStyle(background: Color(0, 255, 0, 255), cursor: .Hand)
]

public class Button: SingleChildWidget, StatefulWidget {
    public typealias State = ButtonState

    public var state: ButtonState = .Normal {
        didSet {
            invalidateRenderState()
        }
    }
    
    public var stateStyles: [ButtonState: ButtonStyle]
    public var cursorRequestId: UInt64? = nil
    public var onClick = EventHandlerManager<GUIMouseButtonClickEvent>()

    private var dropCursorRequest: (() -> ())?

    private var inputChild: Widget

    public init(
        stateStyles: [ButtonState: ButtonStyle] = defaultButtonStyles,
        @WidgetBuilder child inputChildBuilder: () -> Widget,
        onClick onClickHandler: EventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil) {
            self.stateStyles = stateStyles
            if onClickHandler != nil {
                _ = onClick.addHandler(onClickHandler!)
            }
            self.inputChild = inputChildBuilder()
            super.init()
    }

    override open func buildChild() -> Widget {
        MouseArea(onClick: { [unowned self] in
            onClick.invokeHandlers($0)
        }, onMouseEnter: { [unowned self] _ in
            state = .Hover
            // TODO: might need to implement cursor via render object and check in RenderObjectTree renderer which renderobject below mouse
            dropCursorRequest = context!.requestCursor(.Hand)
        }, onMouseLeave: { [unowned self] _ in
            state = .Normal
            dropCursorRequest!()
        }) {
            Padding(all: 16) {
                TextConfigProvider(config: defaultButtonTextConfig) {
                    inputChild
                }
            }
        }
    }

    open func forwardOnClick(_ event: GUIMouseButtonClickEvent) throws {
        try onClick.invokeHandlers(event)
    }

    override open func renderContent() -> RenderObject? {
        let style = stateStyles[state] ?? defaultButtonStyles[state]!
        return RenderObject.Container {
            if state == .Normal {
                RenderObject.RenderStyle(
                    fillColor: FixedRenderValue(Color(0, 255, 120, 255))) {
                        RenderObject.Rectangle(globalBounds)
                }
            } else if state == .Hover {
                RenderObject.RenderStyle(
                    fillColor: TimedRenderValue(
                        id: 0, 
                        startTimestamp: Date.timeIntervalSinceReferenceDate, 
                        duration: 3,
                        valueAt: { progress in Color(UInt8(progress * 255), 0, 0, 255) })) {
                    RenderObject.Rectangle(globalBounds)
                }
            }
            child.render() 
        }
    }

    override open func destroySelf() {
        onClick.removeAllHandlers()
        if let drop = dropCursorRequest {
            drop()
        }
    }
}
