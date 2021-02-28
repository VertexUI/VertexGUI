@dynamicMemberLookup
internal final class WeakBox<T: AnyObject> {
  weak public var wrapped: T?

  init(_ wrapped: T) {
    self.wrapped = wrapped
  }

  subscript<V>(dynamicMember keyPath: KeyPath<T, V>) -> V? {
    wrapped?[keyPath: keyPath]
  }
}