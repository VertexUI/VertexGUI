public protocol MutablePropertyProtocol: ReactiveProperty {
  var value: Value { get set }

  func bind<Source: ReactiveProperty>(_ other: Source) -> UniDirectionalPropertyBinding where Source.Value == Value
}

public extension MutablePropertyProtocol where Value: Equatable {
  // needed to put it inside an extension with Value: Equatable because adding this
  // to the where clause of the function caused a compiler error
  @discardableResult
  func bindBidirectional<Other: MutablePropertyProtocol>(_ other: Other) -> BiDirectionalPropertyBinding where Other.Value == Value {
    let binding = BiDirectionalPropertyBinding(self, other)
    return binding
  }
}

internal protocol InternalMutablePropertyProtocol: MutablePropertyProtocol,
  InternalReactivePropertyProtocol, InternalValueSettableReactivePropertyProtocol {}

extension InternalMutablePropertyProtocol {
  /**
  Add a unidirectional binding to another property. The property bind is called on
  will take the value of the other property when the other property changes. 
  The other property will remain unaffected by any changes to the property bind is called on.
  The value of the other property is immediately assigned to self by this function.
  */
  @discardableResult
  public func bind<Source: ReactiveProperty>(_ other: Source) -> UniDirectionalPropertyBinding where Source.Value == Value {
    let binding = UniDirectionalPropertyBinding(source: other, sink: self)
    return binding
  }
}