//

//

import Foundation
import VisualAppBase
import CustomGraphicsMath

public class Column: Widget {
    public var spacing: Double
    public var wrap: Bool

    /// - Parameter wrap: if max height reached, break (new column) or not break?
    /*public init(wrap: Bool = false, children: [Widget]) {
        self.wrap = wrap
        super.init(children: children)
    }*/

    public init(spacing: Double = 0, wrap: Bool = false, @WidgetBuilder children inputChildrenBuilder: () -> [Widget]) {
        //self.init(wrap: wrap, children: children())
        self.spacing = spacing
        self.wrap = wrap
        super.init(children: inputChildrenBuilder())
    }

    override public func performLayout() {
        var currentX = 0.0
        var currentY = 0.0
        var currentColumnWidth = 0.0 // the current max width for the current column
        var currentMaxHeight = 0.0
        for child in children {
            // check what to set as minSize, maybe height 0 and width self.constraints.minWidth - currentWidth?
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

        bounds.size = DSize2(currentX + currentColumnWidth, currentMaxHeight)
    }
}
