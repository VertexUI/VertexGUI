import VisualAppBase
import CustomGraphicsMath
import WidgetGUI

public struct BoxConfig {
    public var preferredSize: DSize2
    public var minSize: DSize2
    public var maxSize: DSize2
    public var aspectRatio: Double? // width / height = aspectRatio
}

public class LayoutableItem {
    var bounds = DRect(min: .zero, size: .zero)

    var globalParentPosition: DVec2?

    func getBoxConfig() -> BoxConfig {
        fatalError("getBoxConfig() not implemented")
    }

    /// when calling this, bounds should already be set
    /// should be used to calculate positions of children and/or RenderObjects
    func layout() {}

    func render() -> RenderObject {
        fatalError("render() not implemented")
    }
}

public class FlexItem: LayoutableItem {
    var grow: Double
    var wrappedItem: LayoutableItem

    public init(grow: Double, wrapped wrappedItem: LayoutableItem) {
        self.grow = grow
        self.wrappedItem = wrappedItem
    }

    override public func getBoxConfig() -> BoxConfig {
        wrappedItem.getBoxConfig()
    }

    /// when calling this, bounds should already be set
    /// should be used to calculate positions of children and/or RenderObjects
    override public func layout() {
        wrappedItem.globalParentPosition = globalParentPosition! + bounds.min
        wrappedItem.bounds = DRect(min: .zero, size: bounds.size)
        wrappedItem.layout()
    }

    override public func render() -> RenderObject {
        wrappedItem.render()
    }
}

public class FlexRow: LayoutableItem {
    public var items: [FlexItem]

    public init(items: [FlexItem]) {
        self.items = items
    }

    override public func getBoxConfig() -> BoxConfig {
        let preferredSizes = items.compactMap {
            $0.getBoxConfig().preferredSize
        }

        let totalPreferredSize = preferredSizes.reduce(into: DSize2.zero) {
            $0 += $1
        }
        
        return BoxConfig(preferredSize: totalPreferredSize, minSize: .zero, maxSize: .infinity, aspectRatio: nil)
    }

    override public func layout() {
        var currentX = 0.0
        
        var totalGrow = items.reduce(0) { $0 + $1.grow }

        var freeSpace = bounds.size.width - items.reduce(0) { $0 + $1.getBoxConfig().preferredSize.width }

        for item in items {
            let growRatio = item.grow / totalGrow

            let boxConfig = item.getBoxConfig()

            let resultWidth = boxConfig.preferredSize.width + growRatio * freeSpace
            var resultHeight = boxConfig.preferredSize.height

            if let aspectRatio = boxConfig.aspectRatio {
                resultHeight = resultWidth / aspectRatio
            }

            item.bounds.size = DSize2(resultWidth, resultHeight)
            item.bounds.min = globalParentPosition! + DVec2(currentX, 0)
            currentX += item.bounds.size.width

            item.globalParentPosition = globalParentPosition! + bounds.min

            item.layout()
        }
    }

    override public func render() -> RenderObject {
        RenderObject.Container {
            for item in items {
                item.render()
            }
        }
    }
}
/*
public class ConstrainedFlexItem: FlexItem {
    public var grow: Double

    public 
}*/

public class TextItem: LayoutableItem {
    public var text: String
    public var widgetContext: WidgetContext

    private let fontConfig = FontConfig(
        family: defaultFontFamily,
        size: 26,
        weight: .Regular,
        style: .Normal
    )

    public init(_ text: String, widgetContext: WidgetContext) {
        self.text = text
        self.widgetContext = widgetContext
    }

    override public func getBoxConfig() -> BoxConfig {
        let prefSize = widgetContext.getTextBoundsSize(text, fontConfig: fontConfig)
        return BoxConfig(preferredSize: prefSize, minSize: .zero, maxSize: .infinity, aspectRatio: nil)
    }

    override public func layout() {

    }

    override public func render() -> RenderObject {
        return RenderObject.Text(
            text,
            fontConfig: fontConfig,
            color: .Black,
            topLeft: globalParentPosition! + bounds.min)
    }
}

public class ImageItem: LayoutableItem {
    public var color: Color
    public var sourceSize: DSize2

    public init(color: Color, sourceSize: DSize2) {
        self.color = color
        self.sourceSize = sourceSize
    }
    
    override public func getBoxConfig() -> BoxConfig {
        return BoxConfig(
            preferredSize: sourceSize, 
            minSize: .zero, 
            maxSize: .infinity, 
            aspectRatio: sourceSize.width / sourceSize.height)
    }

    override public func layout() {

    }

    override public func render() -> RenderObject {
        return RenderObject.RenderStyle(fillColor: FixedRenderValue(color)) {
            RenderObject.Rectangle(DRect(min: globalParentPosition! + bounds.min, size: bounds.size))
        }
    }
}

public class ExperimentOneView: Widget {
    lazy private var contentRoot = FlexRow(items: [
        FlexItem(
            grow: 1,
            wrapped: TextItem("Test ASD ASD ASD ", widgetContext: context!)),
        FlexItem(
            grow: 0,
            wrapped: ImageItem(color: .Green, sourceSize: DSize2(100, 200))),
        FlexItem(
            grow: 0,
            wrapped: ImageItem(color: .Blue, sourceSize: DSize2(100, 200))),
        FlexItem(
            grow: 0,
            wrapped: ImageItem(color: .Yellow, sourceSize: DSize2(100, 200))),
        FlexItem(
            grow: 1,
            wrapped: ImageItem(color: .Red, sourceSize: DSize2(100, 200))),
        FlexItem(
            grow: 0,
            wrapped: ImageItem(color: .Black, sourceSize: DSize2(100, 200))),
    ])

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