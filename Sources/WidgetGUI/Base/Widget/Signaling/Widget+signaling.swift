public protocol _SignalingWidget: Widget {}

extension _SignalingWidget {
  /// Registers an event handler that will be destroyed when the widget itself is destroyed.
  /// Mainly for use in chaining in UI structure declaration.
  public func on<V>(_ signal: KeyPath<Self, Signal<V>>, handler: @escaping () -> ()) -> Self {
    cancellables.insert(self[keyPath: signal].wrappedValue.sink { _ in
      handler()
    })
    return self
  }

  /// Registers an event handler that will be destroyed when the widget itself is destroyed.
  /// Mainly for use in chaining in UI structure declaration.
  public func on<V>(_ signal: KeyPath<Self, Signal<V>>, handler: @escaping (V) -> ()) -> Self {
    cancellables.insert(self[keyPath: signal].wrappedValue.sink {
      handler($0)
    })
    return self
  }
}

extension Widget: _SignalingWidget {}