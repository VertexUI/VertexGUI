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

public class Button: SingleChildWidget, GUIMouseEventConsumer {
    public var state: ButtonState = .Normal
    public var stateStyles: [ButtonState: ButtonStyle]
    public var cursorRequestId: UInt64? = nil
    public var onClick = EventHandlerManager<Void>()

    public init(child: Widget, stateStyles: [ButtonState: ButtonStyle] = defaultButtonStyles, onClick onClickHandler: EventHandlerManager<Void>.Handler? = nil) {
        self.stateStyles = stateStyles
        if onClickHandler != nil {
            _ = onClick.addHandler(onClickHandler!)
        }
        super.init(child: child)
    }

    override open func layout(fromChild: Bool = false) throws {
        child.constraints = constraints
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
                RenderObject.Rect(globalBounds)
            ),
            child.render()
        ].compactMap { $0 })
    }

    open func consume(_ event: GUIMouseEvent) throws {
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
    }
}