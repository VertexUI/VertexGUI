import OpenCombine

public protocol AnyReferenceProtocol {
    var anyReferenced: Widget? { get set }
}

@propertyWrapper
public class Reference<ReferencedWidget: Widget>: AnyReferenceProtocol, Publisher {
    public typealias Output = ReferencedWidget?
    public typealias Failure = Never

    public unowned var anyReferenced: Widget? {
        get { referenced }
        set {
            if newValue == nil {
                referenced = nil
            } else {
                referenced = newValue as! ReferencedWidget
            }
        }
    }

    public unowned var referenced: ReferencedWidget? {
        didSet {
            publisher.send(referenced)
        }
    }

    public var wrappedValue: ReferencedWidget {
        get {
            return referenced as! ReferencedWidget
        }
        set {
            referenced = newValue
        }
    }

    public var projectedValue: Reference<ReferencedWidget> {
        get {
            self
        }
    }

    public var publisher = PassthroughSubject<Output, Failure>()

    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Input == Output, S.Failure == Failure {
        publisher.receive(subscriber: subscriber)
    }

    public init() {}
}