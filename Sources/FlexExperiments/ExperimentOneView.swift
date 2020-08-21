import VisualAppBase
import CustomGraphicsMath
import WidgetGUI

public struct BoxConfig {
    public var preferredSize: DSize2
    public var minSize: DSize2
    public var maxSize: DSize2
    public var aspectRatio: Double? // width / height = aspectRatio
}

public protocol FlexItem: class {
    var grow: Int { get }
    var bounds: DRect { get set }

    var globalParentPosition: DVec2? { get set }

    func getBoxConfig() -> BoxConfig

    /// when calling this, bounds should already be set
    /// should be used to calculate positions of children and/or RenderObjects
    func layout()

    func render() -> RenderObject
}

public class FlexRow: FlexItem {
    public var items: [FlexItem]
    public var grow: Int
    public var bounds: DRect = DRect(min: .zero, size: .zero)
    public var globalParentPosition: DVec2? {
        didSet {
            for item in items {
                item.globalParentPosition = globalParentPosition
            }
        }
    }

    public init(items: [FlexItem], grow: Int) {
        self.items = items
        self.grow = grow
    }

    public func getBoxConfig() -> BoxConfig {
        let preferredSizes = items.compactMap {
            $0.getBoxConfig().preferredSize
        }

        let totalPreferredSize = preferredSizes.reduce(into: DSize2.zero) {
            $0 += $1
        }
        
        return BoxConfig(preferredSize: totalPreferredSize, minSize: .zero, maxSize: .infinity, aspectRatio: nil)
    }

    public func layout() {
        var currentX = 0.0
        
        for item in items {
            let boxConfig = item.getBoxConfig()
            item.bounds.size = boxConfig.preferredSize
            item.bounds.min = globalParentPosition! + DVec2(currentX, 0)
            currentX += item.bounds.size.width
        }
    }

    public func render() -> RenderObject {
        RenderObject.Container {
            for item in items {
                item.render()
            }
        }
    }
}

public class TextFlexItem: FlexItem {
    public var grow: Int
    public var text: String
    public var widgetContext: WidgetContext
    public var bounds: DRect = DRect(min: .zero, size: .zero)
    public var globalParentPosition: DVec2?

    private let fontConfig = FontConfig(
        family: defaultFontFamily,
        size: 26,
        weight: .Regular,
        style: .Normal
    )

    public init(_ text: String, grow: Int, widgetContext: WidgetContext) {
        self.text = text
        self.grow = grow
        self.widgetContext = widgetContext
    }

    public func getBoxConfig() -> BoxConfig {
        let prefSize = widgetContext.getTextBoundsSize(text, fontConfig: fontConfig)
        return BoxConfig(preferredSize: prefSize, minSize: .zero, maxSize: .infinity, aspectRatio: nil)
    }

    public func layout() {

    }

    public func render() -> RenderObject {
        return RenderObject.Text(
            text,
            fontConfig: fontConfig,
            color: .Black,
            topLeft: globalParentPosition! + bounds.min)
    }
}

public class ImageFlexItem: FlexItem {
    public var color: Color
    public var grow: Int
    public var sourceSize: DSize2
    public var bounds: DRect = DRect(min: .zero, size: .zero)
    public var globalParentPosition: DVec2?

    public init(color: Color, sourceSize: DSize2, grow: Int) {
        self.color = color
        self.sourceSize = sourceSize
        self.grow = grow
    }
    
    public func getBoxConfig() -> BoxConfig {
        return BoxConfig(preferredSize: sourceSize, minSize: .zero, maxSize: .infinity, aspectRatio: nil)
    }

    public func layout() {

    }

    public func render() -> RenderObject {
        return RenderObject.RenderStyle(fillColor: FixedRenderValue(color)) {
            RenderObject.Rectangle(DRect(min: globalParentPosition! + bounds.min, size: sourceSize))
        }
    }
}

public class ExperimentOneView: Widget {
    lazy private var contentRoot = FlexRow(items: [
        TextFlexItem("Test", grow: 1, widgetContext: context!),
        ImageFlexItem(color: .Green, sourceSize: DSize2(100, 200), grow: 0)
    ], grow: 0)

    override public func performLayout() {
        self.bounds.size = constraints!.maxSize
        let rootBoxConfig = contentRoot.getBoxConfig()
        contentRoot.bounds = bounds
        contentRoot.globalParentPosition = DPoint2.zero
        contentRoot.layout()
        print("ROOT BOX CONFIG IS", rootBoxConfig)
    }

    override public func renderContent() -> RenderObject? {
        return contentRoot.render()
    }
}