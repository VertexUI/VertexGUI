import XCTest
@testable import WidgetGUI

final class PropertyTests: XCTestCase {
  func testComputed() {
    var mutable = MutableProperty("Wow")
    var changeCount = 0
    var computed = mutable.compute { Optional<Int>($0.count) }
    _ = computed.onChanged { _ in
      changeCount += 1
    }
    mutable.value = "New Value"
    mutable.value = "New Volau"
    XCTAssertEqual(changeCount, 1)
  }
  
  static var allTests = [
    ("testComputed", testComputed)
  ]
}