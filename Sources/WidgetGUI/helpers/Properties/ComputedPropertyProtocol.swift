public protocol ComputedPropertyProtocol: class {
  associatedtype Value
}

internal protocol AnyEquatableComputedPropertyProtocol {
  func valuesEqual(_ value1: Any?, _ value2: Any?) -> Bool
}