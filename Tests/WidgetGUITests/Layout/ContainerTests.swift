import XCTest
import GfxMath
import ReactiveProperties
@testable import WidgetGUI

class ContainerTests: XCTestCase, LayoutTest {
  func _testOneChild(
    @StylePropertiesBuilder styleProperties stylePropertiesBuilder: (Container.StyleKeys.Type) -> StyleProperties,
    child: Widget,
    rootSize: DSize2,
    assert: (_ outer: Widget, _ inner: Widget) -> ()) {
      let innerRef = Reference<Widget>() 
      let outerRef = Reference<Widget>()
      let root = Root(rootWidget: Container(styleProperties: stylePropertiesBuilder) {
        child.connect(ref: innerRef)
      }.connect(ref: outerRef))
      root.bounds.size = rootSize

      assert(outerRef.referenced!, innerRef.referenced!)
  }

  func testSimpleLinearRowOneFixedChild() {
    let innerRef = Reference<Widget>() 
    let outerRef = Reference<Widget>()
    let root = Root(rootWidget: Container(styleProperties: {
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
    let root = Root(rootWidget: Container(styleProperties: {
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

  func testSimpleLinearRowMultiChildGrow() {
    let innerRef1 = Reference<Widget>() 
    let innerRef2 = Reference<Widget>() 
    let innerRef3 = Reference<Widget>() 
    let outerRef = Reference<Widget>()
    let root = Root(rootWidget: Container().withContent {
      Container(styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        ($0.width, 560.0)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
      }) {
        ExplicitSizeWidget(preferredSize: DSize2(80, 40)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
        }).connect(ref: innerRef1)
        ExplicitSizeWidget(preferredSize: DSize2(120, 70)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 2.0)
        }).connect(ref: innerRef2)
        ExplicitSizeWidget(size: DSize2(80, 60)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
        }).connect(ref: innerRef3)
      }.connect(ref: outerRef)
    })
    root.bounds.size = DSize2(800, 400)

    XCTAssertEqual(outerRef.referenced!.size, DSize2(560, 70))
    XCTAssertEqual(innerRef1.referenced!.size, DSize2(150, 40))
    XCTAssertEqual(innerRef2.referenced!.size, DSize2(260, 70))
    XCTAssertEqual(innerRef3.referenced!.size, DSize2(80, 60))
  }

  func testSimpleLinearRowMultiChildShrink() {
    let innerRef1 = Reference<Widget>() 
    let innerRef2 = Reference<Widget>() 
    let innerRef3 = Reference<Widget>() 
    let outerRef = Reference<Widget>()
    let root = Root(rootWidget: Container().withContent {
      Container(styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        ($0.width, 200.0)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
      }) {
        ExplicitSizeWidget(preferredSize: DSize2(160, 40)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
        }).connect(ref: innerRef1)
        ExplicitSizeWidget(preferredSize: DSize2(140, 70)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 2.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
        }).connect(ref: innerRef2)
        ExplicitSizeWidget(size: DSize2(100, 60)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
        }).connect(ref: innerRef3)
      }.connect(ref: outerRef)
    })
    root.bounds.size = DSize2(800, 400)

    XCTAssertEqual(outerRef.referenced!.size, DSize2(200, 70))
    XCTAssertEqual(innerRef1.referenced!.size, DSize2(110, 40))
    XCTAssertEqual(innerRef2.referenced!.size, DSize2(40, 70))
    XCTAssertEqual(innerRef3.referenced!.size, DSize2(100, 60))
  }

  func testSimpleLinearRowMultiChildStretch() {
    let innerRef1 = Reference<Widget>() 
    let innerRef2 = Reference<Widget>() 
    let innerRef3 = Reference<Widget>() 
    let outerRef = Reference<Widget>()
    let root = Root(rootWidget: Container().withContent {
      Container(styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
      }) {
        ExplicitSizeWidget(preferredSize: DSize2(160, 40)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
        }).connect(ref: innerRef1)
        ExplicitSizeWidget(preferredSize: DSize2(140, 70)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
        }).connect(ref: innerRef2)
        ExplicitSizeWidget(size: DSize2(100, 60)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
        }).connect(ref: innerRef3)
      }.connect(ref: outerRef)
    })
    root.bounds.size = DSize2(800, 400)

    XCTAssertEqual(outerRef.referenced!.size, DSize2(400, 70))
    XCTAssertEqual(innerRef1.referenced!.size, DSize2(160, 70))
    XCTAssertEqual(innerRef2.referenced!.size, DSize2(140, 70))
    XCTAssertEqual(innerRef3.referenced!.size, DSize2(100, 60))
  }

  func testSimpleLinearRowMultiChildJustifyContent() {
    let innerRef1 = Reference<Widget>() 
    let innerRef2 = Reference<Widget>() 
    let outerRef = Reference<Widget>()
    let justifyProperty = MutableProperty<SimpleLinearLayout.Justify>()
    let root = Root(rootWidget: Container().withContent {
      Container(styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
        (SimpleLinearLayout.ParentKeys.justifyContent, justifyProperty)
        ($0.width, 500.0)
      }) {
        ExplicitSizeWidget(preferredSize: DSize2(160, 40)).connect(ref: innerRef1)
        ExplicitSizeWidget(preferredSize: DSize2(140, 70)).connect(ref: innerRef2)
      }.connect(ref: outerRef)
    })
    root.bounds.size = DSize2(800, 400)

    justifyProperty.value = .end
    root.tick()
    XCTAssertEqual(outerRef.referenced!.size, DSize2(500, 70))
    XCTAssertEqual(innerRef1.referenced!.size, DSize2(160, 40))
    XCTAssertEqual(innerRef2.referenced!.size, DSize2(140, 70))
    XCTAssertEqual(innerRef1.referenced!.position, DVec2(200, 0))
    XCTAssertEqual(innerRef2.referenced!.position, DVec2(360, 0))

    justifyProperty.value = .center
    root.tick()
    XCTAssertEqual(outerRef.referenced!.size, DSize2(500, 70))
    XCTAssertEqual(innerRef1.referenced!.size, DSize2(160, 40))
    XCTAssertEqual(innerRef2.referenced!.size, DSize2(140, 70))
    XCTAssertEqual(innerRef1.referenced!.position, DVec2(100, 0))
    XCTAssertEqual(innerRef2.referenced!.position, DVec2(260, 0))

    justifyProperty.value = .start
    root.tick()
    XCTAssertEqual(outerRef.referenced!.size, DSize2(500, 70))
    XCTAssertEqual(innerRef1.referenced!.size, DSize2(160, 40))
    XCTAssertEqual(innerRef2.referenced!.size, DSize2(140, 70))
    XCTAssertEqual(innerRef1.referenced!.position, DVec2(0, 0))
    XCTAssertEqual(innerRef2.referenced!.position, DVec2(160, 0))
  }

  func testSimpleLinearRowMultiChildMixAlignSelfAlignContent() {
    let innerRef1 = Reference<Widget>() 
    let innerRef2 = Reference<Widget>() 
    let innerRef3 = Reference<Widget>() 
    let outerRef = Reference<Widget>()
    let root = Root(rootWidget: Container().withContent {
      Container(styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
        (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.center)
      }) {
        ExplicitSizeWidget(preferredSize: DSize2(160, 40)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
        }).connect(ref: innerRef1)
        ExplicitSizeWidget(preferredSize: DSize2(140, 70)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.end)
        }).connect(ref: innerRef2)
        ExplicitSizeWidget(preferredSize: DSize2(100, 60)).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
        }).connect(ref: innerRef3)
      }.connect(ref: outerRef)
    })
    root.bounds.size = DSize2(800, 400)

    XCTAssertEqual(outerRef.referenced!.size, DSize2(400, 70))
    XCTAssertEqual(innerRef1.referenced!.size, DSize2(160, 70))
    XCTAssertEqual(innerRef1.referenced!.position, DVec2(0, 0))
    XCTAssertEqual(innerRef2.referenced!.size, DSize2(140, 70))
    XCTAssertEqual(innerRef2.referenced!.position, DVec2(160, 0))
    XCTAssertEqual(innerRef3.referenced!.size, DSize2(100, 60))
    XCTAssertEqual(innerRef3.referenced!.position, DVec2(300, 5))
  }

  static var allTests = [
    ("testSimpleLinearRowOneFixedChild", testSimpleLinearRowOneFixedChild),
    ("testSimpleLinearRowOneOverflowingChild", testSimpleLinearRowOneOverflowingChild),
    ("testSimpleLinearRowOneOverflowingChildScrollX", testSimpleLinearRowOneOverflowingChildScrollX),
    ("testSimpleLinearRowOneOverflowingChildScrollY", testSimpleLinearRowOneOverflowingChildScrollY),
    ("testSimpleLinearRowOneOverflowingChildScrollXY", testSimpleLinearRowOneOverflowingChildScrollXY),
    ("testSimpleLinearRowOneChildGrow", testSimpleLinearRowOneChildGrow),
    ("testSimpleLinearRowOneChildShrink", testSimpleLinearRowOneChildShrink),
    ("testSimpleLinearRowOneChildStretch", testSimpleLinearRowOneChildStretch),
    ("testSimpleLinearRowMultiChildGrow", testSimpleLinearRowMultiChildGrow),
    ("testSimpleLinearRowMultiChildShrink", testSimpleLinearRowMultiChildShrink),
    ("testSimpleLinearRowMultiChildStretch", testSimpleLinearRowMultiChildStretch),
    ("testSimpleLinearRowMultiChildJustifyContent", testSimpleLinearRowMultiChildJustifyContent),
    ("testSimpleLinearRowMultiChildMixAlignSelfAlignContent", testSimpleLinearRowMultiChildMixAlignSelfAlignContent)
  ]
}