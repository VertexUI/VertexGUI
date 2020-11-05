public protocol ReferenceProtocol {
    var referenced: Widget? { get set }
}

@propertyWrapper
public class Reference<ReferencedWidget: Widget>: ReferenceProtocol {
    public unowned var referenced: Widget?

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