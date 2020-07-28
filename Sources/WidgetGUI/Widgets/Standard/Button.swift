//

//

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
    public var onClick = EventHandlerManager<GUIMouseButtonClickEvent>()

    private var inputChild: Widget

    public init(
        stateStyles: [ButtonState: ButtonStyle] = defaultButtonStyles,
        onClick onClickHandler: EventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil,
        child inputChild: Widget) {
        self.stateStyles = stateStyles
        if onClickHandler != nil {
            _ = onClick.addHandler(onClickHandler!)
        }
        self.inputChild = inputChild
        super.init()
    }

    override open func buildChild() -> Widget {
        let mouseArea = MouseArea {
            inputChild
        }
        _ = mouseArea.onClick(forwardOnClick)
        _ = mouseArea.onMouseEnter { _ in
            self.state = .Hover
        }
        _ = mouseArea.onMouseLeave { _ in
            self.state = .Normal
        }
        return mouseArea
    }

    public convenience init(
        stateStyles: [ButtonState: ButtonStyle] = defaultButtonStyles,
        onClick onClickHandler: EventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil,
        @WidgetBuilder child: () -> Widget) {
            self.init(stateStyles: stateStyles, onClick: onClickHandler, child: child())
    }

    open func forwardOnClick(_ event: GUIMouseButtonClickEvent) throws {
        try onClick.invokeHandlers(event)
    }

    override open func layout() throws {
        child.constraints = BoxConstraints(
            minSize: constraints!.constrain(constraints!.minSize + DSize2(32, 32)),
            maxSize: constraints!.maxSize)
        try child.layout()
        bounds.size = child.bounds.size
    }
 
    override open func render(_ renderedChild: RenderObject?) -> RenderObject? {
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
            renderedChild
        }
    }

    override open func destroy() throws {
        onClick.removeAllHandlers()
    }
}