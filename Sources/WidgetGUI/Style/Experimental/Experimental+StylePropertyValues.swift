extension Experimental {
  public struct StylePropertyValues<SpecialPropertiesStorage: ExperimentalPartialStylePropertiesStorage>: ExperimentalAnyStylePropertyValues {
    /** keyed by ObjectIdentifier of type of storage (for faster lookup in subscript) */
    public var storages: [ObjectIdentifier: ExperimentalPartialStylePropertiesStorage]

    public init() {
      storages = Dictionary.init(uniqueKeysWithValues: globalStylePropertiesStorageTypes.map {
        (ObjectIdentifier($0), $0.init())
      } + [(ObjectIdentifier(SpecialPropertiesStorage.self), SpecialPropertiesStorage())])
    }

    public subscript<T>(keyPath: KeyPath<SpecialPropertiesStorage, T>) -> T {
      (storages[ObjectIdentifier(SpecialPropertiesStorage.self)] as! SpecialPropertiesStorage)[keyPath: keyPath]
    }
  }
}

public protocol ExperimentalAnyStylePropertyValues {
  var storages: [ObjectIdentifier: ExperimentalPartialStylePropertiesStorage] { get set }

  init()
}