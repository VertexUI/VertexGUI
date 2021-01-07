import XCTest
@testable import WidgetGUI

// TODO: might rename to WidgetStyleApiTests
class ExperimentalStyleTests: XCTestCase {
  class TestContainerWidget: Widget {
    let childrenBuilder: () -> ChildrenBuilder.Result

    public init(@ChildrenBuilder children childrenBuilder: @escaping () -> ChildrenBuilder.Result) {
      self.childrenBuilder = childrenBuilder
    }

    override public func performBuild() {
      let result = childrenBuilder()
      self.children = result.children
    }
  }

  class TestComposedOneChildWidget: Widget {
    let childBuilder: () -> ChildBuilder.Result

    public init(@ChildBuilder child childBuilder: @escaping () -> ChildBuilder.Result) {
      self.childBuilder = childBuilder
    }

    override public func performBuild() {
      let result = childBuilder()
      self.children = [result.child]
    }
  }

  func testContainerWidget() {
    let widget = TestContainerWidget {
      Experimental.Style(".class") {
        ("property1", 1)

        Experimental.Style(".class-1") {
          ("property2", 2)
        }
      }
    }
    let root = MockRoot(rootWidget: widget)
  }

  static var allTests = [
    ("testContainerWidget", testContainerWidget)
  ]
}