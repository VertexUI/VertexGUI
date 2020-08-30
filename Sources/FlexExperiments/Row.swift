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

    private var lines: [Line] = []

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

    // TODO: maybe have box config inside the Widget and then let the parent give the child constraints
    // or maybe one dimension and then the child should decide how to set up the other direction
    override public func getBoxConfig() -> BoxConfig {

        var config = BoxConfig(preferredSize: .zero, minSize: .zero, maxSize: .zero)

        for (index, item) in items.enumerated() {
            
            let content = item.content

            let contentConfig = content.boxConfig

            let spaceAfter = index < items.count - 1 ? spacing : 0.0

            config.preferredSize.width += contentConfig.preferredSize.width + spaceAfter

            if config.preferredSize.height < contentConfig.preferredSize.height {

                config.preferredSize.height = contentConfig.preferredSize.height
            }

            config.minSize.width += contentConfig.minSize.width

            if config.minSize.height < contentConfig.minSize.height {
                
                config.minSize.height = contentConfig.minSize.height
            }

            config.maxSize.width += contentConfig.maxSize.width

            if config.maxSize.height < contentConfig.maxSize.height {

                config.maxSize.height = contentConfig.maxSize.height
            }
        }

        return config
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        print("LAYOUT ROW!", constraints)

        lines = [

            Line(startY: 0, width: 0, height: 0, items: [])
        ]

        var width = 0.0

        var currentX = 0.0
        
        for item in items {

            let content = item.content

            let contentBoxConfig = content.boxConfig

            let freeWidth = constraints.maxWidth - currentX

            let freeHeight = constraints.maxHeight - lines.last!.startY

            var contentConstraints = BoxConstraints(
                
                minSize: .zero,
                
                maxSize: DSize2(freeWidth, freeHeight)
            )

            if item.crossAlignment == .Stretch && contentBoxConfig.preferredSize.height < freeHeight {

                // TODO: is this check for maxHeight of box config necessary or will the widget itself be careful not to go bigger than it can?
                contentConstraints.minSize.height = min(freeHeight, contentBoxConfig.maxSize.height)
            }

            // + 1 at the end to account for floating point precision errors
            if currentX + contentBoxConfig.preferredSize.width >= constraints.maxWidth + 1 {
                
                // TODO: maybe only do this if shrink is set to some value > 0
                if contentBoxConfig.minSize.width > freeWidth {

                    currentX = 0

                    contentConstraints.maxWidth = constraints.maxWidth

                    contentConstraints.maxHeight = constraints.maxHeight - lines.last!.startY - lines.last!.height

                    lines.append(Line(startY: lines.last!.startY + lines.last!.height))
                }

            }

            print("ROW LAYS OUT CONTENT", content, contentConstraints)

            content.layout(constraints: contentConstraints)

            print("content got size:", content.bounds.size)
            
            print("Current X is", currentX)

            content.bounds.min.x = currentX

            content.bounds.min.y = lines.last!.startY

            lines[lines.count - 1].totalGrow += Double(item.grow)

            lines[lines.count - 1].items.append(item)

            lines[lines.count - 1].width += content.bounds.size.width

            currentX += content.bounds.size.width

            if content.bounds.size.height > lines.last!.height {

                lines[lines.count - 1].height = content.bounds.size.height
            }

            // < 1 to account for floating point precision errors
            if (currentX - constraints.maxWidth) < 1 {

                currentX = 0

                lines.append(Line(startY: lines.last!.startY + lines.last!.height))

            } else {
                
                currentX += spacing
            }
        }

        for index in 0..<lines.count {

            var line = lines[index]

            var currentX = 0.0

            let freeWidth = bounds.size.width - line.width

            if index > 0 {

                line.startY = lines[index - 1].startY + lines[index - 1].height
            }

            for item in line.items {
            
                let content = item.content

                content.bounds.min.x = currentX

                if item.grow > 0 {

                    let growWidth = freeWidth * (item.grow / line.totalGrow)

                    content.layout(constraints: BoxConstraints(

                        minSize: DSize2(content.bounds.size.width + growWidth, 0),
                        
                        maxSize: DSize2(content.bounds.size.width + growWidth, .infinity)))
                }

                switch item.crossAlignment {
                    
                case .Center:

                    content.bounds.min.y = line.height / 2 - content.bounds.size.height / 2
                
                default:

                    break
                }

                currentX += content.bounds.size.width

                if content.bounds.size.height > line.height {

                    line.height = content.bounds.size.height
                }

                if currentX > line.width {

                    line.width = currentX
                }

                if currentX > width {

                    width = currentX
                }

                currentX += spacing
            }

            lines[index] = line
        }

        print("after layout, row got size", DSize2(width, lines.last!.startY + lines.last!.height))
        
        print("PREVIOUS SIZE WAS", bounds.size)

        return DSize2(width, lines.last!.startY + lines.last!.height)
    }
}
