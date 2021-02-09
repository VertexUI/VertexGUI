class TestClass {
  @TestWrapper
  public var testVar: String

  func wow() {

  }

  static var theFunctions = [
    (wow)
  ]
}

@propertyWrapper
class TestWrapper {
  public var wrappedValue: String {
    "wow"
  }
}