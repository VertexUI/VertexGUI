public protocol PostInitConfigurableWidget {
  func with<T: Widget>(_ block: (T) -> ()) -> Self
}

extension Widget: PostInitConfigurableWidget {
  public func with<T: Widget>(_ block: (T) -> ()) -> Self {
    guard let castedSelf = self as? T else {
      fatalError("wrong widget type assumed in with(): \(T.self) for widget: \(self)")
    }
    block(castedSelf)
    return self
  }
}