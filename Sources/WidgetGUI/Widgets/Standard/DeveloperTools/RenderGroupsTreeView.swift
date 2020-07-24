import VisualAppBase
import CustomGraphicsMath

public class RenderGroupsTreeView: LeafWidget {
    private var debuggingData: RenderingDebuggingData
    
    public init(debuggingData: RenderingDebuggingData) {
        self.debuggingData = debuggingData
    }

    override open func layout(fromChild: Bool) throws {
        bounds.size = constraints!.maxSize
    }

    override open func render() -> RenderObject? {
        var groups = debuggingData.groups.map {
            RenderObject.Text("WOW \($0.id)", config: TextConfig(
                fontConfig: FontConfig(
                    family: context!.defaultFontFamily,
                    size: 16,
                    weight: .Regular,
                    style: .Normal
                ),
                color: .Black,
                wrap: false
            ), topLeft: globalPosition)
        }
        return RenderObject.RenderStyle(fillColor: FixedRenderValue(Color.Blue)) {
            [RenderObject.Rect(globalBounds)]
            groups
        }
    }
}