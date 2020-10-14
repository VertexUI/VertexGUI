import XCTest
import CustomGraphicsMath
import VisualAppBase
@testable import WidgetGUI

final class FlexTests: XCTestCase {
  func makeRoot(_ rootWidget: Widget) -> Root {
    let root = Root(rootWidget: rootWidget)
    root.widgetContext = WidgetContext(
      window: try! Window(background: .Transparent, size: DSize2(800, 600)),
      getTextBoundsSize: { _, _, _ in DSize2.zero },
      getApplicationTime: { 0 },
      requestCursor: { _ in {} } )
    return root
  }

  func testResultSize(_ widget: Widget, _ size: DSize2, constraints: BoxConstraints = BoxConstraints(minSize: .zero, maxSize: .infinity)) {
    let root = makeRoot(widget)

    widget.layout(constraints: constraints)

    XCTAssertEqual(widget.bounds.size, size)
  }

  func test1() {
    let widget = Row {
      Space(DSize2(200, 10))
    }
    testResultSize(widget, DSize2(200, 10))
  }

  func test2() {
    let widget = Row {
      Space(DSize2(200, 10))
      Space(DSize2(400, 20))
    }
    testResultSize(widget, DSize2(600, 20))
  }

  func test3() {
    let widget = Row(spacing: 20) {
      Space(DSize2(200, 10))
      Space(DSize2(400, 20))
    }
    testResultSize(widget, DSize2(620, 20))
  }

  func test4() {
    let widget = Row {
      Row(spacing: 20) {
        Space(DSize2(200, 10))
        Space(DSize2(300, 20))
      }
    }
    testResultSize(widget, DSize2(520, 20))
  }

  func test5() {
    let widget = Row {
      Space(DSize2(100, 50))
      Row(spacing: 20) {
        Space(DSize2(200, 10))
        Space(DSize2(300, 20))
      }
    }
    testResultSize(widget, DSize2(620, 50))
  }

  func test6() {
    let widget = Row {
      Space(DSize2(100, 50))
      Row.Item(grow: 1) {
        Row(spacing: 40) {
          Space(DSize2(400, 20))
        }
      }
      Row(spacing: 20) {
        Space(DSize2(200, 10))
        Space(DSize2(300, 20))
      }
    }
    testResultSize(widget, DSize2(1020, 50))
    testResultSize(widget, DSize2(1020, 50), constraints: BoxConstraints(minSize: .zero, maxSize: DSize2(1020, 50)))
  }

  func test7() {
    let widget = Column {
      Row {
        Space(DSize2(100, 50))
        Row.Item(grow: 1) {
          Row(spacing: 40) {
            Space(DSize2(400, 20))
          }
        }
        Row(spacing: 20) {
          Space(DSize2(200, 10))
          Space(DSize2(300, 20))
        }
      }
    }
    testResultSize(widget, DSize2(1020, 50))
    testResultSize(widget, DSize2(1020, 50), constraints: BoxConstraints(minSize: .zero, maxSize: DSize2(1020, 50)))
  }

  static var allTests = [
    ("test1", test1),
    ("test2", test2),
    ("test3", test3),
    ("test4", test4),
    ("test5", test5),
    ("test6", test6),
    ("test7", test7)
  ]
}
