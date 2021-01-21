import XCTest
@testable import WidgetGUI

// TODO: might rename to WidgetStyleApiTests
class ExperimentalWidgetStyleApiTests: XCTestCase {
  class ContainerTestWidget: Widget {
    let childrenBuilder: () -> ChildrenBuilder.Result

    public init(@ChildrenBuilder children childrenBuilder: @escaping () -> ChildrenBuilder.Result) {
      self.childrenBuilder = childrenBuilder
    }

    override public func performBuild() {
      let result = childrenBuilder()
      self.children = result.children
    }
  }

  class WidgetWithoutSpecialStyleProperties: Widget {

  }

  class WidgetWithSpecialStyleProperties: Widget, ExperimentalStylableWidget {
    enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case specialProperty1
    }
  }

  class ComposedOneChildTestWidget: Widget {
    let childBuilder: SingleChildContentBuilder.ChildBuilder

    public init(@SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result) {
      self.childBuilder = contentBuilder().child
    }

    override public func performBuild() {
      self.children = [childBuilder()]
    }
  }

  func testSimple() {
    let widget = ContainerTestWidget {
      Experimental.Style(".class") {
        ("property1", 1)

        Experimental.Style(".class-1") {
          ("property2", 2)
        }
      }
    }
    let root = MockRoot(rootWidget: widget)
  }

  func testWidgetWithoutSpecialStyleProperties() {
    let widget = WidgetWithoutSpecialStyleProperties()

    widget.with(styleProperties: {
      ($0.foreground, 1.0)
    })

    XCTAssertEqual(widget.stylePropertyValue(WidgetWithoutSpecialStyleProperties.StyleKeys.foreground) as? Double, 1.0)
  }

  func testWidgetWithSpecialStyleProperties() {
    let widget = WidgetWithSpecialStyleProperties()
    
    widget.with(styleProperties: {
      ($0.foreground, 1.0)
      ($0.specialProperty1, 1.0)
    })
    widget.with(Experimental.StyleProperties(WidgetWithSpecialStyleProperties.StyleKeys.self) {
      ($0.foreground, 2.0)
    })
    widget.with(Experimental.StyleProperties(WidgetWithSpecialStyleProperties.self) {
      ($0.specialProperty1, 3.0)
    })

    XCTAssertEqual(widget.stylePropertyValue(WidgetWithSpecialStyleProperties.StyleKeys.foreground) as? Double, 2.0)
    XCTAssertEqual(widget.stylePropertyValue(WidgetWithSpecialStyleProperties.StyleKeys.specialProperty1) as? Double, 3.0)
  }

  static var allTests = [
    ("testSimple", testSimple),
    ("testWidgetWithoutSpecialStyleProperties", testWidgetWithoutSpecialStyleProperties),
    ("testWidgetWithSpecialStyleProperties", testWidgetWithSpecialStyleProperties)
  ]
}