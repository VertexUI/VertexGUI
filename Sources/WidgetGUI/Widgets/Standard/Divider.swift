import Foundation
import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

open class Divider: Widget {
    public var color: Color
    public var axis: Axis
    public var width: Double

    public init(color: Color, axis: Axis, width: Double = 1) {
        self.color = color
        self.axis = axis
        self.width = width
        super.init()
    }

    override public func getBoxConfig() -> BoxConfig {
        // TODO: implement something like percentage width / height --> fill parent + calculations probably
        switch axis {
        case .Horizontal:
            return BoxConfig(preferredSize: DSize2(100, width))
        case .Vertical:
            return BoxConfig(preferredSize: DSize2(width, 100))
        }
    }

    override open func performLayout() {
        
    }

    override open func renderContent() -> RenderObject? {
        RenderObject.RenderStyle(fillColor: color) {
            RenderObject.Rectangle(globalBounds)
        }
    }
}