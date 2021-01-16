import XCTest
@testable import WidgetGUI

class WidgetStyleScopeApplicationTests: XCTestCase {
  class TestWidget: Experimental.ComposedWidget {
    let buildInternal: ((SingleChildContentBuilder.ChildBuilder?) -> Widget)?
    let childBuilder: SingleChildContentBuilder.ChildBuilder?

    /**
    - Parameter buildInternal: all Widgets created within this function will
    be seen as if they were created by TestWidget implementation itself, the closure gets passed
    the child builder
    */
    init(_ createsStyleScope: Bool,
      buildInternal: ((SingleChildContentBuilder.ChildBuilder?) -> Widget)? = nil,
      @SingleChildContentBuilder content contentBuilder: () -> SingleChildContentBuilder.Result) {
        let content = contentBuilder()
        childBuilder = content.child
        self.buildInternal = buildInternal
        super.init()
        self.createsStyleScope = createsStyleScope
    }

  init(_ createsStyleScope: Bool,
      buildInternal: ((SingleChildContentBuilder.ChildBuilder?) -> Widget)? = nil) {
        self.childBuilder = nil 
        self.buildInternal = buildInternal
        super.init()
        self.createsStyleScope = createsStyleScope
    }

    init(_ createsStyleScope: Bool) {
      self.childBuilder = nil
      self.buildInternal = nil
      super.init()
      self.createsStyleScope = createsStyleScope
    }

    override func performBuild() {
      if let buildInternal = self.buildInternal {
        rootChild = buildInternal(childBuilder)
      } else {
        if let childBuilder = self.childBuilder {
          rootChild = childBuilder()
        }
      }
    }
  }

  func testSingleScopingWidget() {
    let widget = TestWidget(true)
    XCTAssertNil(widget.styleScope)
  }

  func testSingleLayerNestingWithoutScope() {
    let reference1 = Reference<TestWidget>()
    let reference2 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: TestWidget(true) {
      TestWidget(true).connect(ref: reference2)
    }.connect(ref: reference1))

    XCTAssertNil(reference1.referenced!.styleScope)
    XCTAssertNil(reference2.referenced!.styleScope)
  }

  func testSingleLayerNestingWithScope() {
    let reference1 = Reference<TestWidget>()
    let reference2 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: { _ in
      TestWidget(true).connect(ref: reference2)
    }).connect(ref: reference1))

    XCTAssertNil(reference1.referenced!.styleScope)
    XCTAssertEqual(reference2.referenced!.styleScope, reference1.referenced!.id)
  }

  func testThreeLayerNestingWithScope() {
    let reference1 = Reference<TestWidget>()
    let reference2 = Reference<TestWidget>()
    let reference3 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: { childBuilder in
      TestWidget(true) {
        childBuilder!()
      }.connect(ref: reference2)
    }) {
      TestWidget(true).connect(ref: reference3)
    }.connect(ref: reference1))

    XCTAssertNil(reference1.referenced!.styleScope)
    XCTAssertEqual(reference2.referenced!.styleScope, reference1.referenced!.id)
    XCTAssertNil(reference3.referenced!.styleScope)
  }

  static var allTests = [
    ("testSingleScopingWidget", testSingleScopingWidget),
    ("testSingleLayerNestingWithoutScope", testSingleLayerNestingWithoutScope),
    ("testSingleLayerNestingWithScope", testSingleLayerNestingWithScope),
    ("testThreeLayerNestingWithScope", testThreeLayerNestingWithScope)
  ]
}