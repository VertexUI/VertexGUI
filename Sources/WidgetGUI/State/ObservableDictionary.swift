public final class ObservableDictionary<K: Hashable, V>: ExpressibleByDictionaryLiteral {
  public typealias Key = K
  public typealias Value = V

  fileprivate var data: [Key: Value]
  fileprivate var _bindings: [Key: ImmutableBinding<Value?>] = [:]

  lazy public private(set) var bindings = BindingProxy(self)

  public var keys: Dictionary<Key, Value>.Keys {
    data.keys
  }

  public init(dictionaryLiteral: (Key, Value)...) {
    self.data = Dictionary(uniqueKeysWithValues: dictionaryLiteral)
  }

  public init(_ initialData: [Key: Value]) {
    self.data = initialData
  }

  public subscript(_ key: Key) -> Value? {
    get { data[key] }
    set {
      data[key] = newValue
      if let binding = _bindings[key] {
        binding.notifyChange()
      }
    }
  }

  public class BindingProxy<Key: Hashable, Value> {
    unowned let dictionary: ObservableDictionary<Key, Value>

    fileprivate init(_ dictionary: ObservableDictionary<Key, Value>) {
      self.dictionary = dictionary
    }
  
    public subscript(key: Key) -> ReactivePropertyProjection<Value?> {
      if dictionary._bindings[key] == nil {
        dictionary._bindings[key] = ImmutableBinding(get: { [unowned self] in
          dictionary.data[key]
        })
      }

      return dictionary._bindings[key]!.projectedValue
    }
  }
}