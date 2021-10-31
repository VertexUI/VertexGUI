import GfxMath

// TODO: mabye rename to WidgetParent and add children: [Widget]
public protocol Parent: AnyObject {
    var globalPosition: DPoint2 { get }
    var layoutedSize: DSize2 { get }
}