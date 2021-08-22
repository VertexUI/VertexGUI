import Events

public protocol Child: AnyObject {
    var parent: Parent? { get set }

    // TODO: is this necessary?
    var onParentChanged: EventHandlerManager<Parent?> { get }
}
