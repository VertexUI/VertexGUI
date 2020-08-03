/*
open class Flow: Widget {
    override open func performLayout(constraints: BoxConstraints) throws {
        var currentX = 0.0 // relative to topLeft of this Widget
        var currentY = 0.0 // relative to topLeft of this Widget
        var width = 0.0
        var height = 0.0
        for child in children {
            try child.layout(constraints: constraints)

            if currentX + child.bounds.size.width > constraints.maxSize.width {
                currentX = 0.0
                currentY = height
            } 

            child.bounds.min = DPoint2(currentX, currentY)
            currentX += child.bounds.size.width

            if width < constraints.maxSize.width {
                width = min(constraints.maxSize.width, width + child.bounds.size.width)
            }

            if child.bounds.size.height + currentY > height {
                height = currentY + child.bounds.size.height
            }
        }

        bounds.size = Size(
            max(constraints.minSize.width, width),
            max(constraints.minSize.height, height)
        )
    }
}*/
