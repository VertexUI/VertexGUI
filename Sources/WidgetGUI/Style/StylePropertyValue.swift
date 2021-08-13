public enum StylePropertyValue<T> {
  case inherit
  case value(T)

  public init?(_ any: AnyStylePropertyValue) {
    switch any {
    case .inherit:
      self = .inherit
    case let .value(value):
      if let value = value as? T {
        self = .value(value)
      } else {
        return nil
      }
    }
  }
}

public enum AnyStylePropertyValue {
  case inherit
  case value(Any)

  public init?<T>(_ concreteValue: StylePropertyValue<T>?) {
    if let concreteValue = concreteValue {
      self.init(concreteValue)
      return
    }
    return nil
  }

  public init<T>(_ concreteValue: StylePropertyValue<T>) {
    switch concreteValue {
    case .inherit:
      self = .inherit
    case let .value(value):
      self = .value(value)
    }
  }
}