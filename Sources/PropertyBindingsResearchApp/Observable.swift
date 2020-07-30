import VisualAppBase

public struct Observable<Value> {
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
    
    public init(initial initialValue: Value) {
        _value = initialValue
    }
}