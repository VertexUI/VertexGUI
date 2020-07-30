import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class StatefulWidgetOne: Widget, StatefulWidget, GUIMouseEventConsumer {
    public struct State {
        var statePropertyOne: Color = .Blue
        var statePropertyTwo: String = "Default State String"
        var statePropertyThree: Int = 0
    }

    public var state: State = State()

    private var passedPropertyOne: String

    public init(passedPropertyOne: String) {
        self.passedPropertyOne = passedPropertyOne
    }
    
    override open func layout() {
        bounds.size = DSize2(500, 500)
    }

    public func consume(_ event: GUIMouseEvent) {
        if let event = event as? GUIMouseButtonClickEvent {
            if globalBounds.contains(point: event.position) {
                state.statePropertyThree += 1
                invalidateRenderState()
            }
        }
    }

    override open func renderContent() -> RenderObject? {
        return RenderObject.Container {
            RenderObject.RenderStyle(fillColor: FixedRenderValue(state.statePropertyOne)) {
                RenderObject.Rect(Rect(topLeft: globalPosition, size: DSize2(200, 300)))
            }

            RenderObject.Text(passedPropertyOne, fontConfig: FontConfig(
                family: defaultFontFamily,
                size: 16,
                weight: .Regular,
                style: .Normal
            ), color: .Black, topLeft: globalPosition + DVec2(0, 300), wrap: false)

            RenderObject.Text("\(state.statePropertyThree)", fontConfig: FontConfig(
                family: defaultFontFamily,
                size: 16,
                weight: .Regular,
                style: .Normal
            ), color: .Black, topLeft: globalPosition + DVec2(0, 330), wrap: false)
        }
    }
}