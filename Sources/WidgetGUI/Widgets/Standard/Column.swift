//

//

import Foundation
import VisualAppBase
import CustomGraphicsMath

public class Column: Widget {
    public enum Alignment {
        case Start, Center, End, Stretch
    }

    public var spacing: Double
    public var horizontalAlignment: Alignment
    public var wrap: Bool

    /// - Parameter wrap: if max height reached, break (new column) or not break?
    /*public init(wrap: Bool = false, children: [Widget]) {
        self.wrap = wrap
        super.init(children: children)
    }*/

    public init(spacing: Double = 0, horizontalAlignment: Alignment = .Start, wrap: Bool = false, @WidgetBuilder children inputChildrenBuilder: () -> [Widget]) {
        //self.init(wrap: wrap, children: children())
        self.spacing = spacing
        self.horizontalAlignment = horizontalAlignment
        self.wrap = wrap
        super.init(children: inputChildrenBuilder())
    }

    override public func performLayout() {
        var currentX = 0.0
        var currentY = 0.0
        var currentColumnWidth = 0.0 // the current max width for the current column
        var currentMaxHeight = 0.0

        for child in children {
            child.constraints = BoxConstraints(minSize: DSize2(0, 0), maxSize: DSize2(constraints!.maxWidth - currentX, constraints!.maxHeight - currentY))
            try child.layout()

            if wrap {
                if currentY + child.bounds.size.height > constraints!.maxHeight {
                    currentY = 0
                    currentX += currentColumnWidth
                    currentColumnWidth = 0
                }
            }
            child.bounds.min = DPoint2(currentX, currentY)
            currentY += child.bounds.size.height

            if currentColumnWidth < child.bounds.size.width {
                currentColumnWidth = child.bounds.size.width
            }

            if currentY > currentMaxHeight {
                currentMaxHeight = currentY
            }

            currentY += spacing
        }

        bounds.size = constraints!.constrain(DSize2(currentX + currentColumnWidth, currentMaxHeight))

        for child in children {
            switch horizontalAlignment {
            case .Start:
                break
            case .Center:
                child.bounds.min.x = currentColumnWidth / 2 - child.bounds.size.width / 2
            case .End:
                child.bounds.min.x = currentColumnWidth - child.bounds.size.width
            case .Stretch:
                child.constraints = BoxConstraints(size: DSize2(bounds.size.width, child.bounds.size.height))
                child.layout()
            }
        }
    }
}
