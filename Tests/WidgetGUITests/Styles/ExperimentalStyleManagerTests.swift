import XCTest
@testable import WidgetGUI

class ExperimentalStyleManagerTests: XCTestCase {
  class TestWidget: Widget, ExperimentalStylableWidget {
    enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case specificProperty1
    }
  }

  func testSingleWidget() {
    let widget = TestWidget()
    widget.provideStyles([
      Experimental.Style("TestWidget", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      },
      Experimental.Style("&", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      }
    ])
    let styleManager = Experimental.StyleManager()

    styleManager.processTree(widget)
    XCTAssertEqual(widget.experimentalMatchedStyles.count, 2)
    //XCTAssertEqual(widget.stylePropertyValue(TestWidget.StyleKeys.specificProperty1) as! Double, 1.0)
  }

  func testSingleWidgetInContainerWithStylesProcessChild() {
    let widget = TestWidget()
    let container = Experimental.Container {
      Experimental.Style("", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      }

      widget
    }
    let root = MockRoot(rootWidget: container)
    let styleManager = Experimental.StyleManager()

    styleManager.processTree(widget)
    XCTAssertEqual(widget.experimentalMatchedStyles.count, 1)
  }

  func testSingleWidgetInContainerWithStylesProcessRoot() {
    let widget = TestWidget()
    let container = Experimental.Container {
      Experimental.Style("&", Experimental.Container.self) {
        ($0.foreground, 1.0)
      }

      Experimental.Style(".child", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      }

      widget.with(classes: ["child"])
    }
    let styleManager = Experimental.StyleManager()

    styleManager.processTree(container)
    XCTAssertEqual(container.experimentalMatchedStyles.count, 1)
    XCTAssertEqual(widget.experimentalMatchedStyles.count, 1)
    //XCTAssertEqual(widget.stylePropertyValue(TestWidget.StyleKeys.specificProperty1) as! Double, 1.0)
  }

  static var allTests = [
    ("testSingleWidget", testSingleWidget),
    ("testSingleWidgetInContainerWithStylesProcessChild", testSingleWidgetInContainerWithStylesProcessChild),
    ("testSingleWidgetInContainerWithStylesProcessRoot", testSingleWidgetInContainerWithStylesProcessRoot)
  ]
}