import Foundation
import CustomGraphicsMath
import VisualAppBase

open class Divider: Widget {

    public var color: Color

    public var axis: Axis

    public var width: Double

    private var size: DSize2 {
        switch axis {

        case .Horizontal:

            return DSize2(100, width)

        case .Vertical:

            return DSize2(width, 100)
        }
    }

    public init(color: Color, axis: Axis, width: Double = 1) {

        self.color = color

        self.axis = axis

        self.width = width

        super.init()
    }

    override public func getBoxConfig() -> BoxConfig {

        // TODO: implement something like percentage width / height --> fill parent + calculations probably
        BoxConfig(preferredSize: size)
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {
        
        return constraints.constrain(size)
    }

    override open func renderContent() -> RenderObject? {

        RenderObject.RenderStyle(fillColor: color) {

            RenderObject.Rectangle(globalBounds)
        }
    }
}