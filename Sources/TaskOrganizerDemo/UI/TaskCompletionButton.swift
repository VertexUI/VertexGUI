import WidgetGUI
import GfxMath
import VisualAppBase

public class TaskCompletionButton: LeafWidget {
    private let preferredSize = DSize2(16, 16)
    private var completed: Bool

    public init(_ completed: Bool) {
        self.completed = completed
        super.init()
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
        constraints.constrain(preferredSize)
    }

    override public func draw(_ drawingContext: DrawingContext) {
        drawingContext.drawCircle(center: DVec2(layoutedSize / 2), radius: layoutedSize.min()! * 0.9, paint: Paint(strokeWidth: 1.0, strokeColor: foreground))
        if completed {
            drawingContext.drawCircle(center: DVec2(layoutedSize / 2), radius: layoutedSize.min()! * 0.8, paint: Paint(color: foreground))
        }
    }
}
