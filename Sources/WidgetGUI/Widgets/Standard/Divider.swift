import Foundation
import CustomGraphicsMath
import VisualAppBase

open class Divider: Widget {

    public var color: Color

    public var axis: Axis

    public var thickness: Double

    private var orientedSize: DSize2 {
        
        switch axis {

        case .Horizontal:

            return DSize2(100, thickness)

        case .Vertical:

            return DSize2(thickness, 100)
        }
    }

    public init(color: Color, axis: Axis, thickness: Double = 1) {

        self.color = color

        self.axis = axis

        self.thickness = thickness

        super.init()
    }

    override public func getBoxConfig() -> BoxConfig {

        // TODO: implement something like percentage thickness / height --> fill parent + calculations probably
        BoxConfig(preferredSize: orientedSize)
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {
        
        return constraints.constrain(orientedSize)
    }

    override open func renderContent() -> RenderObject? {

        RenderObject.RenderStyle(fillColor: color) {

            RenderObject.Rectangle(globalBounds)
        }
    }
}
