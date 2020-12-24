import XCTest
@testable import ExperimentalReactiveProperties

final class UniDirectionalPropertyBindingTests: XCTestCase {
  func testMutableToMutableBinding() {
    let property1 = MutableProperty("test1")
    let property2 = MutableProperty("test2")
    property1.bind(property2)
    XCTAssertEqual(property1.value, "test2")
    property2.value = "test3"
    XCTAssertEqual(property1.value, "test3")
  }

  func testNotPrepopulatedMutableToMutableBinding() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()
    property1.bind(property2)
    property2.value = "test"
    XCTAssertEqual(property1.value, "test")
  }

  static let allTests = [
    ("testMutableToMutableBinding", testMutableToMutableBinding),
    ("testNotPrepopulatedMutableToMutableBinding", testNotPrepopulatedMutableToMutableBinding)
  ]
}