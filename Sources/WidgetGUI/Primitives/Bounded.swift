import CustomGraphicsMath

public protocol Bounded {
    var globalBounds: DRect { get }
    var bounds: DRect { get set }
}