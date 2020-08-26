import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public class Row: Widget {
    private struct Line {

        public var startY: Double

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

    override public func getBoxConfig() -> BoxConfig {

        var config = BoxConfig(preferredSize: .zero, minSize: .zero, maxSize: .zero)

        config.preferredSize.width += max(0, (Double(items.count) - 1)) * spacing + 1

        for item in items {
            
            let content = item.content

            let contentConfig = content.boxConfig

            config.preferredSize += contentConfig.preferredSize

            config.minSize += contentConfig.minSize

            config.maxSize += contentConfig.maxSize
        }

        return config
    }

    override public func performLayout() {
        var lines = [

            Line(startY: 0, width: 0, height: 0, items: [])
        ]

        //var currentLineHeight = 0.0

        //var currentY = 0.0

        var currentX = 0.0
        
        for item in items {

            let content = item.content

            let boxConfig = content.boxConfig
            
            content.constraints = constraints // legacy

            content.bounds.size = boxConfig.preferredSize

            let freeHeight = bounds.size.height - lines.last!.startY
            
            if boxConfig.preferredSize.height > freeHeight {

                content.bounds.size.height = freeHeight

            } else if item.crossAlignment == .Stretch && boxConfig.preferredSize.height < freeHeight {

                content.bounds.size.height = min(freeHeight, boxConfig.maxSize.height)
            }

            let freeWidth = bounds.size.width - currentX

            // + 1 at the end to account for floating point precision errors
            if currentX + boxConfig.preferredSize.width >= bounds.size.width + 1 {
                
                // TODO: maybe only do this if shrink is set to some value > 0
                if boxConfig.minSize.width <= freeWidth {

                    content.bounds.size.width = freeWidth

                    // TODO: check for aspect ratio
                } else {

                    currentX = 0

                    lines.append(

                        Line(

                            startY: lines.last!.startY + lines.last!.height))
                }
            }
            
            content.bounds.min.x = currentX

            content.bounds.min.y = lines.last!.startY

            lines[lines.count - 1].totalGrow += Double(item.grow)

            lines[lines.count - 1].items.append(item)

            lines[lines.count - 1].width += content.bounds.size.width

            currentX += content.bounds.size.width

            if content.bounds.size.height > lines.last!.height {

                lines[lines.count - 1].height = content.bounds.size.height
            }

            currentX += spacing
        }

        for line in lines {

            var currentX = 0.0

            let freeWidth = bounds.size.width - line.width

            for item in line.items {
            
                let content = item.content

                content.bounds.min.x = currentX

                if item.grow > 0 {

                    let growWidth = freeWidth * (item.grow / line.totalGrow)

                    content.bounds.size.width += growWidth
                }

                currentX += content.bounds.size.width + spacing

                content.layout()
            }
        }
    }
}
