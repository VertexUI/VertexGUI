import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public class Column: Widget, BoxWidget {
    private struct Line {

        public var startX: Double

        public var width: Double = 0

        public var height: Double = 0

        public var items: [Item] = []

        public var totalGrow: Double = 0
    }

    public typealias Item = FlexItem

    private let items: [Item]

    private let spacing: Double

    private let wrap: Bool

    public init(spacing: Double = 0, wrap: Bool = false, items: [Item]) {
        self.items = items
        self.spacing = spacing
        self.wrap = wrap
        super.init()
    }

    public convenience init(spacing: Double = 0, wrap: Bool = false, @FlexItemBuilder items buildItems: () -> [FlexItem]) {
        self.init(spacing: spacing, wrap: wrap, items: buildItems())
    }

    override public func build() {
        children = items.map {
            $0.content
        }
    }

    public func getBoxConfig() -> BoxConfig {

        var config = BoxConfig(preferredSize: .zero, minSize: .zero, maxSize: .zero)
        config.preferredSize.height += max(0, (Double(items.count) - 1)) * spacing + 1

        for item in items {

            let content = item.content

            if let content = content as? BoxWidget {

                let contentConfig = content.getBoxConfig()

                if contentConfig.preferredSize.width > config.preferredSize.width {
                    config.preferredSize.width = contentConfig.preferredSize.width
                }
                config.preferredSize.height += contentConfig.preferredSize.height

                if contentConfig.minSize.width > config.minSize.width {
                    config.minSize.width = contentConfig.minSize.width
                }
                config.minSize.height += contentConfig.minSize.height

                if contentConfig.maxSize.width > config.maxSize.width {
                    config.maxSize.width = contentConfig.maxSize.width
                }
                config.maxSize.height += contentConfig.maxSize.height
            }
        }

        return config
    }

    override public func performLayout() {
        var lines = [

            Line(startX: 0)
        ]

        var currentY = 0.0
        
        for item in items {
            let content = item.content

            if let content = content as? BoxWidget {

                let boxConfig = content.getBoxConfig()
                
                content.constraints = constraints // legacy

                content.bounds.size = boxConfig.preferredSize

                let freeWidth = bounds.size.width - lines.last!.startX

                if item.crossAlignment == .Stretch && boxConfig.preferredSize.width < freeWidth {

                    content.bounds.size.width = min(freeWidth, boxConfig.maxSize.width)
                }

                // + 1 at the end to account for floating point precision errors
                if currentY + boxConfig.preferredSize.height >= bounds.size.height + 1 {

                    currentY = 0

                    lines.append(

                        Line(startX: lines.last!.startX + lines.last!.width)
                    )
                }

                content.bounds.min.x = lines.last!.startX

                content.bounds.min.y = currentY

                lines[lines.count - 1].totalGrow += item.grow

                lines[lines.count - 1].items.append(item)

                lines[lines.count - 1].height += content.bounds.size.height

                currentY += content.bounds.size.height

                if content.bounds.size.width > lines.last!.width {
                    lines[lines.count - 1].width = content.bounds.size.width
                }

                currentY += spacing
            }
        }

        for line in lines {

            let freeHeight = bounds.size.height - line.height

            var currentY = 0.0

            for item in line.items {

                let content = item.content

                content.bounds.min.y = currentY

                if item.grow > 0 {

                    let growHeight = freeHeight * (item.grow / line.totalGrow)

                    content.bounds.size.height += growHeight
                }

                currentY += content.bounds.size.height + spacing

                content.layout()
            }
        }
    }
}
