import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public class Flex: Widget {

    private let orientation: Orientation

    private let mainAxisVectorIndex: Int

    private let crossAxisVectorIndex: Int

    private let items: [Item]

    private let spacing: Double

    private let wrap: Bool

    private var lines: [Line] = []

    public init(orientation: Orientation, spacing: Double = 0, wrap: Bool = false, items: [Item]) {

        self.orientation = orientation

        switch orientation {

        case .Row:
            
            mainAxisVectorIndex = 0

            crossAxisVectorIndex = 1
        
        case .Column:

            mainAxisVectorIndex = 1

            crossAxisVectorIndex = 0
        }

        self.items = items

        self.spacing = spacing

        self.wrap = wrap

        super.init()
    }

    public convenience init(orientation: Orientation, spacing: Double = 0, wrap: Bool = false, @Flex.ItemBuilder items buildItems: () -> [Item]) {

        self.init(orientation: orientation, spacing: spacing, wrap: wrap, items: buildItems())
    }

    /*private func getMainAxisDimension<Vector: Vector2>(_ vector: Vector) -> Double where Vector.Element == Double {

        return vector.x
    }

    private func getCrossAxisDimension<Vector: Vector2>(_ vector: Vector) -> Double where Vector.Element == Double {

        return vector.y
    }*/

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

            config.preferredSize[mainAxisVectorIndex] += contentConfig.preferredSize[mainAxisVectorIndex] + spaceAfter

            if config.preferredSize[crossAxisVectorIndex] < contentConfig.preferredSize[crossAxisVectorIndex] {

                config.preferredSize[crossAxisVectorIndex] = contentConfig.preferredSize[crossAxisVectorIndex]
            }

            config.minSize[mainAxisVectorIndex] += contentConfig.minSize[mainAxisVectorIndex]

            if config.minSize[crossAxisVectorIndex] < contentConfig.minSize[crossAxisVectorIndex] {
                
                config.minSize[crossAxisVectorIndex] = contentConfig.minSize[crossAxisVectorIndex]
            }

            config.maxSize[mainAxisVectorIndex] += contentConfig.maxSize[mainAxisVectorIndex]

            if config.maxSize[crossAxisVectorIndex] < contentConfig.maxSize[crossAxisVectorIndex] {

                config.maxSize[crossAxisVectorIndex] = contentConfig.maxSize[crossAxisVectorIndex]
            }
        }

        return config
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        print("LAYOUT ROW!", constraints)

        lines = [

            Line(crossAxisStart: 0)
        ]

        var mainAxisSize = 0.0

        var mainAxisPosition = 0.0
        
        for item in items {

            let content = item.content

            let contentBoxConfig = content.boxConfig

            let freeMainAxisSpace = constraints.maxSize[mainAxisVectorIndex] - mainAxisPosition

            let freeCrossAxisSpace = constraints.maxSize[crossAxisVectorIndex] - lines.last!.crossAxisStart

            var contentConstraints = BoxConstraints(

                minSize: .zero,
                
                maxSize: DSize2(freeMainAxisSpace, freeCrossAxisSpace)
            )
            
            if item.crossAlignment == .Stretch && contentBoxConfig.preferredSize[crossAxisVectorIndex] < freeCrossAxisSpace {

                // TODO: is this check for maxHeight of box config necessary or will the widget itself be careful not to go bigger than it can?
                contentConstraints.minSize[crossAxisVectorIndex] = min(freeCrossAxisSpace, contentBoxConfig.maxSize[crossAxisVectorIndex])
            }

            var preferredMainAxisSize = contentBoxConfig.preferredSize[mainAxisVectorIndex]

            var explicitMainAxisSizeValue: Double? = nil

            if let explicitMainAxisSize = item.getMainAxisSize(orientation) {

                switch explicitMainAxisSize {
                
                case let .Pixels(value):

                    explicitMainAxisSizeValue = value
                    
                case let .Percent(value):

                    explicitMainAxisSizeValue = constraints.maxSize[mainAxisVectorIndex] * value / 100
                }

                contentConstraints.maxSize[mainAxisVectorIndex] = explicitMainAxisSizeValue!

                if explicitMainAxisSizeValue!.isFinite {

                    preferredMainAxisSize = explicitMainAxisSizeValue!

                    contentConstraints.minSize[mainAxisVectorIndex] = explicitMainAxisSizeValue!
                }
            }

            mainAxisPosition += item.getMainAxisStartMargin(orientation)

            // + 1 at the end to account for floating point precision errors
            if mainAxisPosition + preferredMainAxisSize >= constraints.maxSize[mainAxisVectorIndex] + 1 {
                
                // TODO: maybe only do this if shrink is set to some value > 0
                if contentBoxConfig.minSize[mainAxisVectorIndex] > freeMainAxisSpace {

                    mainAxisPosition = item.getMainAxisStartMargin(orientation)

                    if explicitMainAxisSizeValue == nil {

                        contentConstraints.maxSize[mainAxisVectorIndex] = constraints.maxSize[mainAxisVectorIndex]
                    }

                    contentConstraints.maxSize[crossAxisVectorIndex] = constraints.maxSize[crossAxisVectorIndex] - lines.last!.crossAxisStart - lines.last!.size[crossAxisVectorIndex]

                    lines.append(Line(crossAxisStart: lines.last!.crossAxisStart + lines.last!.size[crossAxisVectorIndex]))
                }
            }

            print("ROW LAYS OUT CONTENT", content, contentConstraints)

            content.layout(constraints: contentConstraints)

            print("content got size:", content.bounds.size)
            
            print("Current X is", mainAxisPosition)

            content.bounds.min[mainAxisVectorIndex] = mainAxisPosition

            content.bounds.min[crossAxisVectorIndex] = lines.last!.crossAxisStart + item.getCrossAxisStartMargin(orientation)

            lines[lines.count - 1].totalGrow += Double(item.grow)

            lines[lines.count - 1].items.append(item)

            lines[lines.count - 1].size[mainAxisVectorIndex] += content.bounds.size[mainAxisVectorIndex]

            mainAxisPosition += content.bounds.size[mainAxisVectorIndex] + item.getMainAxisEndMargin(orientation)

            let marginedCrossAxisItemSize = content.bounds.size[crossAxisVectorIndex] + item.getCrossAxisStartMargin(orientation) + item.getCrossAxisEndMargin(orientation)

            if marginedCrossAxisItemSize > lines.last!.size[crossAxisVectorIndex] {

                lines[lines.count - 1].size[crossAxisVectorIndex] = marginedCrossAxisItemSize
            }

            if mainAxisPosition > mainAxisSize {

                mainAxisSize = mainAxisPosition
            }

            // < 1 to account for floating point precision errors
            if abs(mainAxisPosition - constraints.maxSize[mainAxisVectorIndex]) < 1 {

                mainAxisPosition = 0

                lines.append(Line(crossAxisStart: lines.last!.crossAxisStart + lines.last!.size[crossAxisVectorIndex]))

            } else {
                
                mainAxisPosition += spacing
            }
        }



        // second pass through all lines
        for index in 0..<lines.count {

            var line = lines[index]

            var mainAxisPosition = 0.0

            let freeMainAxisSpace: Double

            if constraints.maxSize[mainAxisVectorIndex].isFinite {

                freeMainAxisSpace = constraints.maxSize[mainAxisVectorIndex] - line.size[mainAxisVectorIndex]

            } else {

                freeMainAxisSpace = mainAxisSize - line.size[mainAxisVectorIndex]
            }

            if index > 0 {

                line.crossAxisStart = lines[index - 1].crossAxisStart + lines[index - 1].size[crossAxisVectorIndex]
            }


           /* // first pass through items in line, apply explicit widths, heights
            for item in line.items {

                let content = item.content
                
                var newConstraints = BoxConstraints(
                    minSize: .zero,
                    maxSize: .infinity
                )

                var relayout = false
                
                if let explicitHeight = item[crossAxisVectorIndex] {

                    let heightValue: Double

                    switch explicitHeight {

                    case .Pixels(value):

                        heightValue = value

                    case .Percentage(value):

                        heightValue = value * constraints.maxSize[mainAxisVectorIndex]
                    }
                }

                if relayout {

                    content.layout(constraints: newConstraints)
                }

                mainAxisPosition += content.bounds.size[mainAxisVectorIndex]

                if mainAxisPosition > line[mainAxisVectorIndex] {

                    line[mainAxisVectorIndex] = mainAxisPosition
                }

                // TODO: maybe check for height as well?
            }


            mainAxisPosition = 0*/

            // second pass through items in line, grow rest free space
            // TODO: might avoid this if no item has grow
            for item in line.items {

                let content = item.content

                var newConstraints = BoxConstraints(
                    minSize: .zero,
                    maxSize: .infinity
                )

                var relayout = false

                mainAxisPosition += item.getMainAxisStartMargin(orientation)

                content.bounds.min[mainAxisVectorIndex] = mainAxisPosition

                if item.grow > 0 {

                    let mainAxisGrowSpace = freeMainAxisSpace * (item.grow / line.totalGrow)

                    newConstraints = BoxConstraints(

                        minSize: DSize2(content.bounds.size[mainAxisVectorIndex] + mainAxisGrowSpace, 0),
                        
                        maxSize: DSize2(content.bounds.size[mainAxisVectorIndex] + mainAxisGrowSpace, .infinity))

                    relayout = true
                }

                if relayout {

                    content.layout(constraints: newConstraints)
                }

                switch item.crossAlignment {
                    
                case .Center:

                    let marginedCrossAxisItemSize = content.bounds.size[crossAxisVectorIndex] + item.getCrossAxisStartMargin(orientation) + item.getCrossAxisEndMargin(orientation)

                    content.bounds.min[crossAxisVectorIndex] = line.crossAxisStart + line.size[crossAxisVectorIndex] / 2 - marginedCrossAxisItemSize / 2
                
                default:

                    break
                }

                mainAxisPosition += content.bounds.size[mainAxisVectorIndex] + item.getMainAxisEndMargin(orientation)

                if content.bounds.size[crossAxisVectorIndex] > line.size[crossAxisVectorIndex] {

                    line.size[crossAxisVectorIndex] = content.bounds.size[crossAxisVectorIndex]
                }

                if mainAxisPosition > line.size[mainAxisVectorIndex] {

                    line.size[mainAxisVectorIndex] = mainAxisPosition
                }

                if mainAxisPosition > mainAxisSize {

                    mainAxisSize = mainAxisPosition
                }

                mainAxisPosition += spacing
            }


            lines[index] = line
        }



        print("after layout, row got size", DSize2(mainAxisSize, lines.last!.crossAxisStart + lines.last!.size[crossAxisVectorIndex]))
        
        print("PREVIOUS SIZE WAS", bounds.size)

        switch orientation {

            case .Row:
            
                return constraints.constrain(DSize2(mainAxisSize, lines.last!.crossAxisStart + lines.last!.size[crossAxisVectorIndex]))

            case .Column:

                return constraints.constrain(DSize2(lines.last!.crossAxisStart + lines.last!.size[crossAxisVectorIndex], mainAxisSize))
        }
    }
}

extension Flex {

    public enum Orientation {

        case Row, Column
    }

    private struct Line {

        public var crossAxisStart: Double

        public var size: DSize2 = .zero

        public var items: [Item] = []
        
        public var totalGrow: Double = 0
    }

    public struct Item {

        public enum FlexValue {

            case Pixels(_ value: Double)

            case Percent(_ value: Double)
        }

        var grow: Double

        var crossAlignment: FlexAlignment

        var content: Widget

        var width: FlexValue?

        var height: FlexValue?

        var margins: Margins

        public init(

            grow: Double = 0,

            crossAlignment: FlexAlignment = .Start,

            width: FlexValue? = nil,

            height: FlexValue? = nil,

            margins: Margins = Margins(all: 0),

            @WidgetBuilder content contentBuilder: @escaping () -> Widget) {

                self.grow = grow

                self.crossAlignment = crossAlignment

                self.width = width

                self.height = height

                self.margins = margins

                self.content = contentBuilder()
        }

        public func getMainAxisSize(_ orientation: Orientation) -> FlexValue? {

            switch orientation {
            
            case .Row:

                return width

            case .Column:

                return height
            }
        }

        public func getCrossAxisSize(_ orientation: Orientation) -> FlexValue? {

            switch orientation {

            case .Row:

                return height
            
            case .Column:

                return width
            }
        }

        public func getMainAxisStartMargin(_ orientation: Orientation) -> Double {

            switch orientation {

            case .Row:

                return margins.left
            
            case .Column:

                return margins.top
            }
        }

        public func getMainAxisEndMargin(_ orientation: Orientation) -> Double {

            switch orientation {

            case .Row:

                return margins.right
            
            case .Column:

                return margins.bottom
            }
        }

        public func getCrossAxisStartMargin(_ orientation: Orientation) -> Double {

            switch orientation {

            case .Row:

                return margins.top
            
            case .Column:

                return margins.left
            }
        }

        public func getCrossAxisEndMargin(_ orientation: Orientation) -> Double {

            switch orientation {

            case .Row:

                return margins.bottom
            
            case .Column:

                return margins.right
            }
        }
    }

    @_functionBuilder
    public struct ItemBuilder {
        public static func buildExpression(_ widget: Widget) -> [Flex.Item] {
            [Flex.Item { widget }]
        }

        public static func buildExpression(_ widgets: [Widget]) -> [Flex.Item] {
            widgets.map { widget in Flex.Item { widget } }
        }

        public static func buildExpression(_ item: Flex.Item) -> [Flex.Item] {
            [item]
        }

        public static func buildExpression(_ items: [Flex.Item]) -> [Flex.Item] {
            items
        }

        public static func buildOptional(_ items: [Flex.Item]?) -> [Flex.Item] {

            return items ?? []
        }

        public static func buildBlock(_ items: [Flex.Item]...) -> [Flex.Item] {
            items.flatMap { $0 }
        }

        public static func buildArray(_ items: [[Flex.Item]]) -> [Flex.Item] {
            items.flatMap { $0 }
        }
    }
}