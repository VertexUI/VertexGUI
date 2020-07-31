import VisualAppBase

public protocol Child: class {
    var parent: Parent? { get set }

    var onParentChanged: EventHandlerManager<Parent?> { get }
    var onAnyParentChanged: EventHandlerManager<Parent?> { get }
}
