import VisualAppBase

public protocol Child: class {
    var parent: Parent? { get set }

    var onParentChanged: ThrowingEventHandlerManager<Parent?> { get }
    var onAnyParentChanged: ThrowingEventHandlerManager<Parent?> { get }
}