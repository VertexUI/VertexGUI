public protocol AnyReferenceProtocol {
    var anyReferenced: Widget? { get set }
}

@propertyWrapper
public class Reference<ReferencedWidget: Widget>: AnyReferenceProtocol {
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

    public unowned var referenced: ReferencedWidget?

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

    public init() {}
}