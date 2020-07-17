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
    public var state: ButtonState = .Normal
    public var stateStyles: [ButtonState: ButtonStyle]
    public var cursorRequestId: UInt64? = nil
    public var onClick = EventHandlerManager<GUIMouseButtonClickEvent>()

    private var mouseArea: MouseArea {
        child as! MouseArea
    }

    public init(
        stateStyles: [ButtonState: ButtonStyle] = defaultButtonStyles,
        onClick onClickHandler: EventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil,
        child: Widget) {
        self.stateStyles = stateStyles
        if onClickHandler != nil {
            _ = onClick.addHandler(onClickHandler!)
        }
        
        super.init(child:
            MouseArea(child: child)
        )
        _ = mouseArea.onClick(forwardOnClick)
        _ = mouseArea.onMouseEnter { _ in
            self.state = .Hover
        }
        _ = mouseArea.onMouseLeave { _ in
            self.state = .Normal
        }
    }

    open func forwardOnClick(_ event: GUIMouseButtonClickEvent) throws {
        try onClick.invokeHandlers(event)
    }

    override open func layout(fromChild: Bool = false) throws {
        child.constraints = BoxConstraints(
            minSize: constraints!.constrain(constraints!.minSize + DSize2(32, 32)),
            maxSize: constraints!.maxSize)
        try child.layout()
        bounds.size = child.bounds.size
    }
 
    override open func render() -> RenderObject? {
        let style = stateStyles[state] ?? defaultButtonStyles[state]!
        //try renderer.rect(globalBounds, style: RenderStyle(fillColor: style.background))
        //try child.render(renderer: renderer)
        return .Container([
            RenderObject.RenderStyle(
                RenderStyle(fillColor: style.background),
                [RenderObject.Rect(globalBounds)]
            ),
            child.render()
        ].compactMap { $0 })
    }

    /*open func consume(_ event: GUIMouseEvent) throws {
        print("BUTTON CONSUMES MOUSE EVENT")
        /*switch event {
        case is MouseEnterEvent:
            self.state = .Hover
            if (cursorRequestId == nil) {
                cursorRequestId = try context?.system.requestCursor(.Hand)
            }
        case is MouseLeaveEvent:
            self.state = .Normal
            if (cursorRequestId != nil) {
                try context?.system.dropCursorRequest(id: cursorRequestId!)
                cursorRequestId = nil
            }
        case is MouseButtonDownEvent:
            try onClick.invokeHandlers(Void())
        default:
            break
        }*/
    }*/
}