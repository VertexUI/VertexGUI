import WidgetGUI
import GfxMath
import VisualAppBase

public class TaskCompletionButton: Widget, LeafWidget {
    @FromStyle(key: StyleKeys.foreground)
    private var color: Color = .white
    private let preferredSize = DSize2(16, 16)
    private var completed: Bool

    public init(
        classes: [String]? = nil,
        @Experimental.StylePropertiesBuilder styleProperties buildStyleProperties: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
        _ completed: Bool, onClick onClickHandler: (() -> ())? = nil) {
            self.completed = completed
            super.init()
            if let classes = classes {
                self.classes.append(contentsOf: classes)
            }
            self.with(buildStyleProperties(StyleKeys.self))
            if let handler = onClickHandler {
                onClick(handler)
            }
    }

    override public func getContentBoxConfig() -> BoxConfig {
        BoxConfig(preferredSize: preferredSize)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
        constraints.constrain(preferredSize)
    }

    public func draw(_ drawingContext: DrawingContext) {
        drawingContext.drawCircle(center: DVec2(size / 2), radius: size.min()! * 0.9, paint: Paint(strokeWidth: 1.0, strokeColor: color))
        if completed {
            drawingContext.drawCircle(center: DVec2(size / 2), radius: size.min()! * 0.8, paint: Paint(color: color))
        }
    }
}
