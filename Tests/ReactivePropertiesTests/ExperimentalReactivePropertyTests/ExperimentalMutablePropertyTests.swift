import XCTest
@testable import ExperimentalReactiveProperties

final class ExperimentalMutablePropertyTests: XCTestCase {
  func testInstantiation() {
    let property = MutableProperty("testString")
    XCTAssertEqual(property.value, "testString")
  }

  func testValueSet() {
    let property = MutableProperty("testString")
    property.value = "testString2"
    XCTAssertEqual(property.value, "testString2")
  }

  func testOnChanged() {
    let property = MutableProperty("testString")
    var handlerCallCount = 0
    let removeHandler = property.onChanged {
      handlerCallCount += 1

      XCTAssertEqual($0.old, "testString")
      XCTAssertEqual($0.new, "testString2")
    }
    property.value = "testString2"
    XCTAssertEqual(handlerCallCount, 1)
  }

  static let allTests = [
    ("testInstantiation", testInstantiation),
    ("testValueSet", testValueSet),
    ("testOnChanged", testOnChanged)
  ]
}