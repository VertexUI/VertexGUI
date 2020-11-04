import VisualAppBase

public protocol Child: class {
    var parent: Parent? { get set }

    // TODO: is this necessary?
    var onParentChanged: EventHandlerManager<Parent?> { get }
}
