public protocol MutablePropertyProtocol: ReactiveProperty {
  var value: Value { get set }

  @discardableResult
  func bind<Source: ReactiveProperty>(_ other: Source) -> UniDirectionalPropertyBinding where Source.Value == Value
}