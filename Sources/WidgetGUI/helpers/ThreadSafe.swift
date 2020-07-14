import Foundation

@propertyWrapper
public struct ThreadSafe<T> {
    private var value: T
    private var semaphore = DispatchSemaphore(value: 1)
    public init(wrappedValue: T) { value = wrappedValue }
    public var wrappedValue: T {
        get {
            semaphore.wait()
            defer { semaphore.signal() }
            return value
        }
        set {
            semaphore.wait()
            value = newValue
            semaphore.signal()
        }
    }
}