import XCTest
@testable import WidgetGUI

class WidgetStyleScopeApplicationTests: XCTestCase {
  class TestWidget: Widget {
    let buildInternal: ((MultiChildContentBuilder.ChildrenBuilder?) -> [Widget])?
    let childrenBuilder: MultiChildContentBuilder.ChildrenBuilder?

    /**
    - Parameter buildInternal: all Widgets created within this function will
    be seen as if they were created by TestWidget implementation itself, the closure gets passed
    the child builder
    */
    init(_ createsStyleScope: Bool,
      buildInternal: ((MultiChildContentBuilder.ChildrenBuilder?) -> [Widget])?,
      @MultiChildContentBuilder content contentBuilder: () -> MultiChildContentBuilder.Result) {
        let content = contentBuilder()
        childrenBuilder = content.childrenBuilder
        self.buildInternal = buildInternal
        super.init()
        self.createsStyleScope = createsStyleScope
    }

  init(_ createsStyleScope: Bool,
      buildInternal: @escaping (MultiChildContentBuilder.ChildrenBuilder?) -> [Widget]) {
        self.childrenBuilder = nil 
        self.buildInternal = buildInternal
        super.init()
        self.createsStyleScope = createsStyleScope
    }

    init(_ createsStyleScope: Bool) {
      self.childrenBuilder = nil
      self.buildInternal = nil
      super.init()
      self.createsStyleScope = createsStyleScope
    }

    override func performBuild() {
      if let buildInternal = self.buildInternal {
        children = buildInternal(childrenBuilder)
      } else {
        if let childrenBuilder = self.childrenBuilder {
          children = childrenBuilder()
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
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: nil) {
      TestWidget(true).connect(ref: reference2)
    }.connect(ref: reference1))

    XCTAssertNil(reference1.referenced!.styleScope)
    XCTAssertNil(reference2.referenced!.styleScope)
  }

  func testSingleLayerNestingWithScope() {
    let reference1 = Reference<TestWidget>()
    let reference2 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: { _ in
      [TestWidget(true).connect(ref: reference2)]
    }).connect(ref: reference1))

    XCTAssertNil(reference1.referenced!.styleScope)
    XCTAssertEqual(reference2.referenced!.styleScope, reference1.referenced!.id)
  }

  func testThreeLayerNestingWithScope() {
    let reference1 = Reference<TestWidget>()
    let reference2 = Reference<TestWidget>()
    let reference3 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: { childrenBuilder in
      [TestWidget(true, buildInternal: nil) {
        childrenBuilder!()
      }.connect(ref: reference2)]
    }) {
      TestWidget(true).connect(ref: reference3)
    }.connect(ref: reference1))

    XCTAssertNil(reference1.referenced!.styleScope)
    XCTAssertEqual(reference2.referenced!.styleScope, reference1.referenced!.id)
    XCTAssertNil(reference3.referenced!.styleScope)
  }

  func testMultiChildComplexNestingWithScope() {
    let reference1 = Reference<TestWidget>()
    let reference2 = Reference<TestWidget>()
    let reference3 = Reference<TestWidget>()
    let reference4 = Reference<TestWidget>()
    let reference5 = Reference<TestWidget>()
    let reference6 = Reference<TestWidget>()
    let reference7 = Reference<TestWidget>()
    let reference8 = Reference<TestWidget>()
    let reference9 = Reference<TestWidget>()
    let reference10 = Reference<TestWidget>()
    let reference11 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: { _ in
      [
        TestWidget(true, buildInternal: nil) {
          TestWidget(true).connect(ref: reference2)

          TestWidget(true, buildInternal: nil) {
            TestWidget(true).connect(ref: reference4)
          }.connect(ref: reference3)
        }.connect(ref: reference1),

        TestWidget(true, buildInternal: { childrenBuilder in
          [
            TestWidget(true, buildInternal: nil) {
              TestWidget(true).connect(ref: reference9)
            },
            TestWidget(false, buildInternal: { _ in
              [
                TestWidget(true, buildInternal: nil) {
                  TestWidget(true).connect(ref: reference11)
                }.connect(ref: reference10)
              ]
            }).connect(ref: reference6)
          ] + childrenBuilder!()
        }) {
          TestWidget(true, buildInternal: nil) {
            TestWidget(true).connect(ref: reference8)
          }.connect(ref: reference7)
        }.connect(ref: reference5)
      ]
    }))

    XCTAssertEqual(reference1.referenced!.styleScope, root.rootWidget.id)
    XCTAssertEqual(reference2.referenced!.styleScope, root.rootWidget.id)
    XCTAssertEqual(reference3.referenced!.styleScope, root.rootWidget.id)
    XCTAssertEqual(reference4.referenced!.styleScope, root.rootWidget.id)
    XCTAssertEqual(reference5.referenced!.styleScope, root.rootWidget.id)
    XCTAssertEqual(reference9.referenced!.styleScope, reference5.referenced!.id)
    XCTAssertEqual(reference6.referenced!.styleScope, reference5.referenced!.id)
    XCTAssertEqual(reference10.referenced!.styleScope, reference5.referenced!.id)
    XCTAssertEqual(reference11.referenced!.styleScope, reference5.referenced!.id)
    XCTAssertEqual(reference7.referenced!.styleScope, root.rootWidget.id)
    XCTAssertEqual(reference8.referenced!.styleScope, root.rootWidget.id)
  }

  static var allTests = [
    ("testSingleScopingWidget", testSingleScopingWidget),
    ("testSingleLayerNestingWithoutScope", testSingleLayerNestingWithoutScope),
    ("testSingleLayerNestingWithScope", testSingleLayerNestingWithScope),
    ("testThreeLayerNestingWithScope", testThreeLayerNestingWithScope),
    ("testMultiChildComplexNestingWithScope", testMultiChildComplexNestingWithScope)
  ]
}