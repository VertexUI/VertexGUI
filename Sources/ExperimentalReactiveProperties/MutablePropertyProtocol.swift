public protocol MutablePropertyProtocol: ReactiveProperty {
  var value: Value { get set }

  func bind<Source: ReactiveProperty>(_ other: Source) where Source.Value == Value
}