extension Widget {
  public func resolve(widgetDimensionSize value: WidgetDimensionSize) -> Double {
    switch value {
      case let .a(value): return value
      case let .rw(percent): return context.getRootSize().width * percent / 100
      case let .rh(percent): return context.getRootSize().height * percent / 100
    }
  }
}