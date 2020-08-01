import CustomGraphicsMath
import VisualAppBase

// TODO: mabye rename to WidgetParent and add children: [Widget]
public protocol Parent: class {
    var globalPosition: DPoint2 { get }
}