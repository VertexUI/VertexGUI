import VisualAppBase

public class Observable<Value> {
    private var _value: Value
    public var value: Value {
        get {
            return _value
        }

        set {
            _value = newValue
            onChanged.invokeHandlers(_value)
        }
    }
    public internal(set) var onChanged = EventHandlerManager<Value>()
    
    public init(_ initialValue: Value) {
        _value = initialValue
    }
}
/*
@propertyWrapper
public struct Observe<Value> {
    var wrappedValue: Observable<Value>
    
    public init(wrappedValue: Observable<Value>) {
        self.wrappedValue = wrappedValue
    }
}*/