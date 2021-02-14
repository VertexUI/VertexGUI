import XCTest
import GfxMath
@testable import WidgetGUI

class ContainerTests: XCTestCase, LayoutTest {
  func _testOneChild(
    @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (Experimental.Container.StyleKeys.Type) -> Experimental.StyleProperties,
    child: Widget,
    rootSize: DSize2,
    assert: (_ outer: Widget, _ inner: Widget) -> ()) {
      let innerRef = Reference<Widget>() 
      let outerRef = Reference<Widget>()
      let root = Root(rootWidget: Experimental.Container(styleProperties: stylePropertiesBuilder) {
        child.connect(ref: innerRef)
      }.connect(ref: outerRef))
      root.bounds.size = rootSize

      assert(outerRef.referenced!, innerRef.referenced!)
  }

  func testSimpleLinearRowOneFixedChild() {
    let innerRef = Reference<Widget>() 
    let outerRef = Reference<Widget>()
    let root = Root(rootWidget: Experimental.Container(styleProperties: {
      ($0.layout, SimpleLinearLayout.self)
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
    }) {
      ExplicitSizeWidget(size: DSize2(80, 40)).connect(ref: innerRef)
    }.connect(ref: outerRef))
    root.bounds.size = DSize2(800, 400)

    XCTAssertEqual(outerRef.referenced!.size, DSize2(800, 400))
    XCTAssertEqual(innerRef.referenced!.size, DSize2(80, 40))
  }

  func testSimpleLinearRowOneOverflowingChild() {
    let innerRef = Reference<Widget>() 
    let outerRef = Reference<Widget>()
    let root = Root(rootWidget: Experimental.Container(styleProperties: {
      ($0.layout, SimpleLinearLayout.self)
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
    }) {
      ExplicitSizeWidget(size: DSize2(8000, 4000)).connect(ref: innerRef)
    }.connect(ref: outerRef))
    root.bounds.size = DSize2(800, 400)

    XCTAssertEqual(outerRef.referenced!.size, DSize2(8000, 4000))
    XCTAssertEqual(innerRef.referenced!.size, DSize2(8000, 4000))
  }

  func testSimpleLinearRowOneOverflowingChildScrollX() {
    _testOneChild(
      styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
        ($0.overflowX, Overflow.scroll)
      },
      child: ExplicitSizeWidget(preferredSize: DSize2(800, 400)),
      rootSize: DSize2(80, 40),
      assert: {
        XCTAssertEqual($0.size, DSize2(80, 40))
        XCTAssertEqual($1.size, DSize2(800, 40))
      }
    )
  }

  func testSimpleLinearRowOneOverflowingChildScrollY() {
    _testOneChild(
      styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
        ($0.overflowY, Overflow.scroll)
      },
      child: ExplicitSizeWidget(preferredSize: DSize2(800, 400)),
      rootSize: DSize2(80, 40),
      assert: {
        XCTAssertEqual($0.size, DSize2(80, 40))
        XCTAssertEqual($1.size, DSize2(800, 400))
      }
    )
  }

  func testSimpleLinearRowOneOverflowingChildScrollXY() {
    _testOneChild(
      styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
        ($0.overflowX, Overflow.scroll)
        ($0.overflowY, Overflow.scroll)
      },
      child: ExplicitSizeWidget(size: DSize2(800, 400)),
      rootSize: DSize2(80, 40),
      assert: {
        XCTAssertEqual($0.size, DSize2(80, 40))
        XCTAssertEqual($1.size, DSize2(800, 400))
      }
    )
  }

  func testSimpleLinearRowOneChildGrow() {
    _testOneChild(
      styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
      },
      child: ExplicitSizeWidget(preferredSize: DSize2(80, 20), maxSize: DSize2(2000.0, 2000.0)).with(styleProperties: { _ in
        (SimpleLinearLayout.ChildKeys.grow, 1.0)
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
      }),
      rootSize: DSize2(800, 40),
      assert: {
        XCTAssertEqual($0.size, DSize2(800, 40))
        XCTAssertEqual($1.size, DSize2(800, 20))
      }
    )
  }

  func testSimpleLinearRowOneChildShrink() {
    _testOneChild(
      styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
      },
      child: ExplicitSizeWidget(preferredSize: DSize2(1600, 20), minSize: DSize2(1200, 0)).with(styleProperties: { _ in
        (SimpleLinearLayout.ChildKeys.grow, 1.0)
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
      }),
      rootSize: DSize2(800, 40),
      assert: {
        XCTAssertEqual($0.size, DSize2(1200, 40))
        XCTAssertEqual($1.size, DSize2(1200, 20))
      }
    )
  }

  func testSimpleLinearRowOneChildStretch() {
    _testOneChild(
      styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
      },
      child: ExplicitSizeWidget(preferredSize: DSize2(1600, 20), minSize: DSize2(1200, 0)).with(styleProperties: { _ in
        (SimpleLinearLayout.ChildKeys.grow, 1.0)
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
      }),
      rootSize: DSize2(800, 40),
      assert: {
        XCTAssertEqual($0.size, DSize2(1200, 40))
        XCTAssertEqual($1.size, DSize2(1200, 40))
      }
    )
  }

  static var allTests = [
    ("testSimpleLinearRowOneFixedChild", testSimpleLinearRowOneFixedChild),
    ("testSimpleLinearRowOneOverflowingChild", testSimpleLinearRowOneOverflowingChild),
    ("testSimpleLinearRowOneOverflowingChildScrollX", testSimpleLinearRowOneOverflowingChildScrollX),
    ("testSimpleLinearRowOneOverflowingChildScrollY", testSimpleLinearRowOneOverflowingChildScrollY),
    ("testSimpleLinearRowOneOverflowingChildScrollXY", testSimpleLinearRowOneOverflowingChildScrollXY),
    ("testSimpleLinearRowOneChildGrow", testSimpleLinearRowOneChildGrow),
    ("testSimpleLinearRowOneChildShrink", testSimpleLinearRowOneChildShrink),
    ("testSimpleLinearRowOneChildStretch", testSimpleLinearRowOneChildStretch)
  ]
}