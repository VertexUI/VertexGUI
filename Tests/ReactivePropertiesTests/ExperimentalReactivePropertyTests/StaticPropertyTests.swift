import XCTest
@testable import ExperimentalReactiveProperties

final class StaticPropertyTests: XCTestCase {
  func testSimpleStaticProperty() {
    let property = StaticProperty("testString")
    XCTAssertEqual(property.value, "testString")
  }

  static let allTests = [
    ("testSimpleStaticProperty", testSimpleStaticProperty)
  ]
}