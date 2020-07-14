import CustomGraphicsMath
import VisualAppBase

public protocol Parent: class {
    var globalPosition: DPoint2 { get }

    func relayout() throws
}