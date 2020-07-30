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

public let defaultButtonTextConfig = TextConfig(
    fontConfig: FontConfig(
        family: defaultFontFamily, size: 16, weight: .Bold, style: .Normal),
    transform: .Uppercase,
    color: .Black,
    wrap: false)

public let defaultButtonStyles: [ButtonState: ButtonStyle] = [
    .Normal: ButtonStyle(background: Color(255, 0, 0, 255), cursor: .Arrow),
    .Hover: ButtonStyle(background: Color(0, 255, 0, 255), cursor: .Hand)
]

public class Button: SingleChildWidget {
    public var state: ButtonState = .Normal {
        didSet {
            invalidateRenderState()
        }
    }
    public var stateStyles: [ButtonState: ButtonStyle]
    public var cursorRequestId: UInt64? = nil
    public var onClick = ThrowingEventHandlerManager<GUIMouseButtonClickEvent>()

    private var dropCursorRequest: (() -> ())?

    private var inputChildBuilder: () -> Widget

    public init(
        stateStyles: [ButtonState: ButtonStyle] = defaultButtonStyles,
        onClick onClickHandler: ThrowingEventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil,
        @WidgetBuilder child inputChildBuilder: @escaping () -> Widget) {
            self.stateStyles = stateStyles
            if onClickHandler != nil {
                _ = onClick.addHandler(onClickHandler!)
            }
            self.inputChildBuilder = inputChildBuilder
            super.init()
    }

    override open func buildChild() -> Widget {
        let mouseArea = MouseArea {
            Padding(all: 16) {
                TextConfigProvider(config: defaultButtonTextConfig) {
                    inputChildBuilder()
                }
            }
        }
        _ = mouseArea.onClick(forwardOnClick)
        _ = mouseArea.onMouseEnter { _ in
            self.state = .Hover
            // TODO: might need to implement cursor via render object and check in RenderObjectTree renderer which renderobject below mouse
            self.dropCursorRequest = self.context!.requestCursor(.Hand)
        }
        _ = mouseArea.onMouseLeave { _ in
            self.state = .Normal
            self.dropCursorRequest!()
        }
        return mouseArea
    }

    open func forwardOnClick(_ event: GUIMouseButtonClickEvent) throws {
        try onClick.invokeHandlers(event)
    }

    override open func renderContent() -> RenderObject? {
        let style = stateStyles[state] ?? defaultButtonStyles[state]!
        return RenderObject.Container {
            if state == .Normal {
                RenderObject.RenderStyle(fillColor: FixedRenderValue(Color(0, 255, 120, 255))) {
                    RenderObject.Rect(globalBounds)
                }
            } else if state == .Hover {
                RenderObject.RenderStyle(
                    fillColor: TimedRenderValue(
                        startTimestamp: Date.timeIntervalSinceReferenceDate, 
                        duration: 3, id: 0, valueAt: { progress in Color(UInt8(progress * 255), 0, 0, 255) })) {
                    RenderObject.Rect(globalBounds)
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