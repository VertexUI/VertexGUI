import XCTest
@testable import WidgetGUI

class ExperimentalStyleTests: XCTestCase {
  func testParentTracking() {
    let style = Experimental.Style("") {
      Experimental.Style("") {
        Experimental.Style("") {

        }
      }

      Experimental.Style("") {

      }
    }

    XCTAssertNotNil(style.children[0].parent)
    XCTAssertNotNil(style.children[0].children[0].parent)
    XCTAssertNotNil(style.children[1].parent)
  }

  static var allTests = [
    ("testParentTracking", testParentTracking)
  ]
}