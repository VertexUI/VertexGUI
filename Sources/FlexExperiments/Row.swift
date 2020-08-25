import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public class Row: Widget, BoxWidget {
    public struct Item {
        var grow: Int
        var crossAlignment: Alignment
        var content: Widget

        public init(grow: Int = 0, crossAlignment: Alignment = .Start, @WidgetBuilder content contentBuilder: @escaping () -> Widget) {
            self.grow = grow
            self.crossAlignment = crossAlignment
            self.content = contentBuilder()
        }

        public func getBoxConfig() -> BoxConfig {
            BoxConfig(preferredSize: .zero)
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
        config.preferredSize.width += max(0, (Double(items.count) - 1)) * spacing + 1

        for item in items {
            let content = item.content

            if let content = content as? BoxWidget {
                let contentConfig = content.getBoxConfig()
                config.preferredSize += contentConfig.preferredSize
                config.minSize += contentConfig.minSize
                config.maxSize += contentConfig.maxSize
            }
        }

        return config
    }

    override public func performLayout() {
        var currentLineHeight = 0.0
        var currentY = 0.0
        var currentX = 0.0
        
        for item in items {
            let content = item.content

            if let content = content as? BoxWidget {
                let boxConfig = content.getBoxConfig()
                
                content.constraints = constraints // legacy

                content.bounds.size = boxConfig.preferredSize

                let freeHeight = bounds.size.height - currentY
                
                if boxConfig.preferredSize.height > freeHeight {
                    content.bounds.size.height = freeHeight
                } else if item.crossAlignment == .Stretch && boxConfig.preferredSize.height < freeHeight {
                    content.bounds.size.height = min(freeHeight, boxConfig.maxSize.height)
                    print("STRETCHHHHHHHHhhh", content, content.bounds.size.height, freeHeight, boxConfig.maxSize.height)
                }

                // + 1 at the end to account for floating point precision errors
                if currentX + boxConfig.preferredSize.width >= bounds.size.width + 1 {
                    let freeWidth = bounds.size.width - currentX
                    
                    if boxConfig.minSize.width <= freeWidth {
                        content.bounds.size.width = freeWidth 
                        // TODO: check for aspect ratio
                    } else {
                        currentX = 0
                        currentY += currentLineHeight
                        currentLineHeight = 0
                    }
                }
                
                content.bounds.min.x = currentX
                content.bounds.min.y = currentY

                content.layout()

                currentX += content.bounds.size.width

                if content.bounds.size.height > currentLineHeight {
                    currentLineHeight = content.bounds.size.height
                }

                currentX += spacing
            }
        }
    }
}
