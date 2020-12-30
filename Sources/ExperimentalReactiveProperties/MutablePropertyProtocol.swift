public protocol MutablePropertyProtocol: ReactiveProperty {
  var value: Value { get set }
}

public extension MutablePropertyProtocol where Value: Equatable {
  // needed to put it inside an extension with Value: Equatable because adding this
  // to the where clause of the function caused a compiler error
  @discardableResult
  func bind<Source: ReactiveProperty>(_ other: Source) -> UniDirectionalPropertyBinding where Source.Value == Value, Value: Equatable {
    fatalError("not implemented")
  }
}