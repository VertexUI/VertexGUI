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
    let childBuilder: () -> ChildBuilder.Result

    public init(@ChildBuilder child childBuilder: @escaping () -> ChildBuilder.Result) {
      self.childBuilder = childBuilder
    }

    override public func performBuild() {
      let result = childBuilder()
      self.children = [result.child]
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
      ($0.foreground, 1)
    })

    widget.updateAppliedStyleProperties()

    XCTAssertEqual(widget.experimentalAppliedStyleProperties.count, 1)
  }

  func testWidgetWithSpecialStyleProperties() {
    let widget = WidgetWithSpecialStyleProperties()
    
    widget.with(styleProperties: {
      ($0.foreground, 1)
      ($0.specialProperty1, 1)
    })
    widget.with(Experimental.StyleProperties(WidgetWithSpecialStyleProperties.StyleKeys.self) {
      ($0.foreground, 1)
    })
    widget.with(Experimental.StyleProperties(WidgetWithSpecialStyleProperties.self) {
      ($0.specialProperty1, 1)
    })

    widget.updateAppliedStyleProperties()

    XCTAssertEqual(widget.experimentalAppliedStyleProperties.count, 2)
    // TODO: test in more depth!
  }

  static var allTests = [
    ("testSimple", testSimple),
    ("testWidgetWithoutSpecialStyleProperties", testWidgetWithoutSpecialStyleProperties),
    ("testWidgetWithSpecialStyleProperties", testWidgetWithSpecialStyleProperties)
  ]
}