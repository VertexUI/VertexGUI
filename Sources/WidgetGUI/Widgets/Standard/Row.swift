import CustomGraphicsMath
import VisualAppBase

public class Row: Widget {

    @_functionBuilder
    public struct ItemBuilder {
        public static func buildExpression(_ widget: Widget) -> Item {
            return Item(grow: 0, verticalAlignment: .Start, content: { widget })
        }

        public static func buildExpression(_ item: Item) -> Item {
            return item
        }

        public static func buildBlock(_ items: Item?...) -> [Item] {
            return items.compactMap { $0 }
        }

        public static func buildBlock(_ items: [Item]) -> [Item] {
            return items
        }
        /*
        public static func buildEither(first: Item) -> Item {
            return first
        }

        public static func buildEither(second: Item) -> Item {
            return second
        }

        public static func buildOptional(_ item: Item?) -> Item? {
            return item
        }

        public static func buildOptional(_ widget: Widget?) -> Item? {
            if let widget = widget {
                return Item(content: { widget })
            }

            return nil
        }*/
    }

    public struct Item {
        var grow: Int
        var verticalAlignment: Alignment
        var contentBuilder: () -> Widget

        public init(grow: Int = 0, verticalAlignment: Alignment = .Start, @WidgetBuilder content contentBuilder: @escaping () -> Widget) {
            self.grow = grow
            self.verticalAlignment = verticalAlignment
            self.contentBuilder = contentBuilder
        }
    }

    public enum Alignment {
        case Start, Center, End
    }

    private let items: [Item]

    private let spacing: Double

    private let wrap: Bool

    /*public init(wrap: Bool = false, children: [Widget]) {
        self.wrap = wrap
        super.init(children: children)
    }*/

    public init(spacing: Double = 0, wrap: Bool = false, @ItemBuilder items itemBuilder: () -> [Item]) {
        self.items = itemBuilder()
        self.spacing = spacing
        self.wrap = wrap
        super.init()
    }

    override public func build() {
        children = items.map {
            $0.contentBuilder()
        }
    }

    override public func performLayout() {
        var currentX = 0.0
        var currentY = 0.0
        var maxWidth = 0.0
        var currentRowHeight = 0.0 // height of the current line of children, if multiline, total height = currentY + currentRowHeight

        var totalGrow = 0

        for i in 0..<children.count {
            let child = children[i]
            let item = items[i]
            
            totalGrow += item.grow

            // TODO: maybe set min size as well

            if wrap {
                child.constraints = BoxConstraints(minSize: .zero, maxSize: constraints!.maxSize)
                child.layout()

                if currentX + child.bounds.size.width > constraints!.maxWidth {
                    currentX = 0
                    currentY += currentRowHeight
                }
            } else {
                // TODO: should the width of the items be limited to the remaining width or to the full width?
                child.constraints = BoxConstraints(minSize: DSize2(0,0), maxSize: DSize2(constraints!.maxWidth/* - currentX*/, constraints!.maxHeight/* - currentY*/))
                child.layout()
            }

            child.bounds.min = DPoint2(currentX, currentY)
            currentX += child.bounds.size.width

            if child.bounds.size.height > currentRowHeight {
                currentRowHeight = child.bounds.size.height
            }

            if currentX > maxWidth {
                maxWidth = currentX
            }

            currentX += spacing
        }

        bounds.size = DSize2(max(constraints!.minWidth, maxWidth), max(constraints!.minHeight, currentY + currentRowHeight))

        let availableWidth = constraints!.minWidth - maxWidth

        // TODO: need to implement this for multi line also!
        // --> grow relative to the items in the same row, fill the row
        // align vertically inside the row

        currentX = 0

        for i in 0..<children.count {
            let child = children[i]
            let item = items[i]

            if availableWidth > 0 && totalGrow > 0 {
                
                let relativeGrow: Double

                if totalGrow == 0 {
                    relativeGrow = 0
                } else {
                    relativeGrow = Double(item.grow) / Double(totalGrow)
                }

                let targetWidth = child.bounds.size.width + availableWidth * relativeGrow
                child.constraints = BoxConstraints(minSize: DSize2(targetWidth, child.bounds.size.height), maxSize: DSize2(targetWidth, child.bounds.size.height))
                child.layout()

                child.bounds.min.x = currentX
                currentX += child.bounds.size.width + spacing
            }

            switch item.verticalAlignment {

            case .Center:
                child.bounds.min.y = bounds.size.height / 2 - child.bounds.size.height / 2
                
            case .End:
                child.bounds.min.y = bounds.size.height - child.bounds.size.height

            default:
                break
            }
        }
    }
}
