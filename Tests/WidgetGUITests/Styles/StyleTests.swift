import XCTest
@testable import WidgetGUI

class StyleTests: XCTestCase {
  func testParentTracking() {
    let style = Style("") {
      Style("") {
        Style("") {

        }
      }

      Style("") {

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