public struct Dependency {
  public internal(set) var value: Any
  public internal(set) var key: String?
  public init<T>(_ value: T, key: String? = nil) {
    self.value = value
    self.key = key
  }
}

