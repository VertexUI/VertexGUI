import CustomGraphicsMath
import VisualAppBase

public class Row: MultiChildWidget {
    public var wrap: Bool

    /*public init(wrap: Bool = false, children: [Widget]) {
        self.wrap = wrap
        super.init(children: children)
    }*/

    public init(wrap: Bool = false, @WidgetBuilder children: () -> [Widget]) {
        self.wrap = wrap
        super.init(children: children())
        //self.init(wrap: wrap, children: children())
    }

    override public func layout() throws {
        var currentX = 0.0
        var currentY = 0.0
        var maxWidth = 0.0
        var currentRowHeight = 0.0 // height of the current line of children, if multiline, total height = currentY + currentRowHeight
        for child in children {
            // TODO: maybe set min size as well
            child.constraints = BoxConstraints(minSize: DSize2(0,0), maxSize: DSize2(constraints!.maxWidth - currentX, constraints!.maxHeight - currentY))
            try child.layout()

            if wrap {
                if currentX + child.bounds.size.width > constraints!.maxWidth {
                    currentX = 0
                    currentY += currentRowHeight
                }
            }

            child.bounds.topLeft = DPoint2(currentX, currentY)
            currentX += child.bounds.size.width

            if child.bounds.size.height > currentRowHeight {
                currentRowHeight = child.bounds.size.height
            }


            if currentX > maxWidth {
                maxWidth = currentX
            }
        }
        bounds.size = DSize2(max(constraints!.minWidth, maxWidth), max(constraints!.minHeight, currentY + currentRowHeight))
    }
}