import VisualAppBase
import CustomGraphicsMath
import WidgetGUI

public struct FlexRow {
    public var items: [FlexItem]

    public init(items: [FlexItem]) {
        self.items = items
    }
}

public protocol FlexItem {
    var grow: Int { get }

    func render() -> RenderObject
}

public struct TextFlexItem: FlexItem {
    public var grow: Int
    public var text: String

    public init(_ text: String, grow: Int) {
        self.text = text
        self.grow = grow
    }

    public func render() -> RenderObject {
        return RenderObject.Text(
            text,
            fontConfig: FontConfig(
                family: defaultFontFamily,
                size: 16,
                weight: .Regular,
                style: .Normal
            ),
            color: .Black,
            topLeft: .zero)
    }
}

public struct ImageFlexItem: FlexItem {
    public var color: Color
    public var grow: Int
    public var sourceSize: DSize2

    public init(color: Color, sourceSize: DSize2, grow: Int) {
        self.color = color
        self.sourceSize = sourceSize
        self.grow = grow
    }

    public func render() -> RenderObject {
        return RenderObject.RenderStyle(fillColor: FixedRenderValue(color)) {
            RenderObject.Rectangle(DRect(min: DPoint2(0, 0), size: sourceSize))
        }
    }
}

public class ExperimentOneView: Widget {
    private let content = FlexRow(items: [
        TextFlexItem("Test", grow: 1),
        ImageFlexItem(color: .Green, sourceSize: DSize2(100, 200), grow: 0)
    ])

    override public func performLayout() {
        self.bounds.size = constraints!.maxSize
    }

    override public func renderContent() -> RenderObject? {
        return RenderObject.Container {
            for flexItem in content.items {
                flexItem.render()
            }
        }
    }
}