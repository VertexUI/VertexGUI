import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public class Column: Widget, BoxWidget {
    public struct Item {
        var grow: Int
        var verticalAlignment: Alignment
        var content: Widget

        public init(grow: Int = 0, verticalAlignment: Alignment = .Start, @WidgetBuilder content contentBuilder: @escaping () -> Widget) {
            self.grow = grow
            self.verticalAlignment = verticalAlignment
            self.content = contentBuilder()
        }
    }

    public enum Alignment {
        case Start, Center, End, Stretch
    }

    private let items: [Item]

    private let spacing: Double

    private let wrap: Bool

    public init(spacing: Double = 0, wrap: Bool = false, items: [Item]) {
        self.items = items
        self.spacing = spacing
        self.wrap = wrap
        super.init()
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
                config.maxSize.width += contentConfig.maxSize.width
            }
        }

        return config
    }

    override public func performLayout() {
        var currentColumnWidth = 0.0
        var currentY = 0.0
        var currentX = 0.0
        
        for item in items {
            let content = item.content

            if let content = content as? BoxWidget {
                let boxConfig = content.getBoxConfig()
                
                content.constraints = constraints // legacy

                // + 1 at the end to account for floating point precision errors
                if currentY + boxConfig.preferredSize.height >= bounds.size.height + 1 {
                    currentY = 0
                    currentX += currentColumnWidth
                    currentColumnWidth = 0
                }

                content.bounds.size = boxConfig.preferredSize
                content.bounds.min.x = currentX
                content.bounds.min.y = currentY

                content.layout()

                currentY += content.bounds.size.height

                if content.bounds.size.width > currentColumnWidth {
                    currentColumnWidth = content.bounds.size.width
                }

                currentY += spacing
            }
        }
    }
}
