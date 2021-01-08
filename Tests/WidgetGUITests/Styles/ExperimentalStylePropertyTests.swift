import XCTest
import ExperimentalReactiveProperties
@testable import WidgetGUI

class ExperimentalStylePropertyTests: XCTestCase {
  func testReactivePropertyValue() {
    let reactiveProperty = MutableProperty(1.0)
    let styleProperty = Experimental.StyleProperty(key: "testKey", value: reactiveProperty)
    XCTAssertEqual(styleProperty.value as! Double, 1.0)
    XCTAssertTrue(styleProperty.canChange)

    var onChangedCalled = false
    _ = styleProperty.onChanged {
      onChangedCalled = true
    }
    reactiveProperty.value = 2.0
    XCTAssertTrue(onChangedCalled)
    XCTAssertEqual(styleProperty.value as! Double, 2.0)
  }

  static var allTests = [
    ("testReactivePropertyValue", testReactivePropertyValue)
  ]
}