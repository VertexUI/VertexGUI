import XCTest
import VisualAppBase
import GfxMath
@testable import WidgetGUI

class ExperimentalStyleManagerTests: XCTestCase {
  class TestWidget: Widget, ExperimentalStylableWidget {
    enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case specificProperty1
    }
  }

  class MockRoot: Root {
    override public init(rootWidget: Widget) {
      super.init(rootWidget: rootWidget)
      self.setup(widgetContext: WidgetContext(
        window: try! Window(options: Window.Options()),
        getTextBoundsSize: { _, _, _ in DSize2.zero },
        getApplicationTime: { 0 },
        getRealFps: { 0 },
        createWindow: { _, _ in try! Window(options: Window.Options()) },
        requestCursor: { _ in {} } ))
    }
    
    override func setup(widgetContext: WidgetContext) {
      self.widgetContext = widgetContext
      rootWidget.mount(parent: self, context: widgetContext, lifecycleBus: widgetLifecycleBus)
    }

    public func mockTick() {
      tick(Tick(deltaTime: 0, totalTime: 0))
    }
  }

  func testSingleWidget() {
    let widget = TestWidget()
    widget.provideStyles([
      Experimental.Style("", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      },
      Experimental.Style("&", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      }
    ])
    let root = MockRoot(rootWidget: widget)
    let styleManager = Experimental.StyleManager()

    styleManager.processTree(widget)
    XCTAssertEqual(widget.experimentalMatchedStyles.count, 1)
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
    XCTAssertEqual(container.experimentalMatchedStyles.count, 0)
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
    let root = MockRoot(rootWidget: container)
    let styleManager = Experimental.StyleManager()

    styleManager.processTree(container)
    XCTAssertEqual(container.experimentalMatchedStyles.count, 1)
    XCTAssertEqual(widget.experimentalMatchedStyles.count, 1)
  }

  func testMultipleWidgetsInNestedContainersWithStylesProcessRoot() {
    let reference1 = Reference<Experimental.Container>()
    let reference2 = Reference<Experimental.Container>()
    let reference3 = Reference<Experimental.Container>()
    let reference4 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: Experimental.Container {
      Experimental.Style("&") {}

      Experimental.Container(classes: ["class-1"]) {
        Experimental.Style("&.class-1") {}
        Experimental.Style(".class-1") {}

        Experimental.Container(classes: ["class-2"]) {
          Experimental.Style(".class-1") {}

          TestWidget().with(classes: ["class-1"]).connect(ref: reference4)
        }.connect(ref: reference3)
      }.connect(ref: reference2)
    }.connect(ref: reference1))
    let styleManager = Experimental.StyleManager()
    styleManager.processTree(root.rootWidget)

    XCTAssertEqual(reference1.referenced!.experimentalMatchedStyles.count, 1)
    XCTAssertEqual(reference2.referenced!.experimentalMatchedStyles.count, 1)
    XCTAssertEqual(reference3.referenced!.experimentalMatchedStyles.count, 0)
    XCTAssertEqual(reference4.referenced!.experimentalMatchedStyles.count, 2)
  }

  func testMultipleWidgetsInNestedContainersWithStylesProcessChild() {
    let reference1 = Reference<Experimental.Container>()
    let reference2 = Reference<Experimental.Container>()
    let reference3 = Reference<Experimental.Container>()
    let reference4 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: Experimental.Container {
      Experimental.Style("&") {}

      Experimental.Container(classes: ["class-1"]) {
        Experimental.Style("&.class-1") {}
        Experimental.Style(".class-1") {}

        Experimental.Container(classes: ["class-2"]) {
          Experimental.Style(".class-1") {}

          TestWidget().with(classes: ["class-1"]).connect(ref: reference4)
        }.connect(ref: reference3)
      }.connect(ref: reference2)
    }.connect(ref: reference1))
    let styleManager = Experimental.StyleManager()
    styleManager.processTree(reference4.referenced!)

    XCTAssertEqual(reference1.referenced!.experimentalMatchedStyles.count, 0)
    XCTAssertEqual(reference2.referenced!.experimentalMatchedStyles.count, 0)
    XCTAssertEqual(reference3.referenced!.experimentalMatchedStyles.count, 0)
    XCTAssertEqual(reference4.referenced!.experimentalMatchedStyles.count, 2)
  }

  func testSingleWidgetWithNestedStyles() {
    let widget = TestWidget()
    widget.with(classes: ["class-1"])
    widget.provideStyles([
      Experimental.Style("&") {
        Experimental.Style("&") {
          Experimental.Style("&.class-1") {}

          Experimental.Style("&") {}

          // should not match
          Experimental.Style("") {}
        }
        
        // should not match
        Experimental.Style(".class-1") {}
      }
    ])
    let styleManager = Experimental.StyleManager()

    styleManager.processTree(widget)
    XCTAssertEqual(widget.experimentalMatchedStyles.count, 4)
  }

  func testMultipleWidgetsInNestedContainersWithNestedStylesProcessRoot() {
    let reference1 = Reference<Experimental.Container>()
    let reference2 = Reference<Experimental.Container>()
    let reference3 = Reference<Experimental.Container>()
    let reference4 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: Experimental.Container {
      Experimental.Style("&") {
        Experimental.Style("&.class-1") {}
        Experimental.Style(".class-1") {}
      }

      Experimental.Container(classes: ["class-1"]) {
        Experimental.Style("& &.class-1") {
          Experimental.Style(".class-1") {}
        }

        Experimental.Container(classes: ["class-2"]) {
          Experimental.Style(".class-1") {
            Experimental.Style("&.class-1") {}
          }

          TestWidget().with(classes: ["class-1"]).connect(ref: reference4)
        }.connect(ref: reference3)
      }.connect(ref: reference2)
    }.connect(ref: reference1))
    let styleManager = Experimental.StyleManager()
    styleManager.processTree(root.rootWidget)

    XCTAssertEqual(reference1.referenced!.experimentalMatchedStyles.count, 1)
    XCTAssertEqual(reference2.referenced!.experimentalMatchedStyles.count, 2)
    XCTAssertEqual(reference3.referenced!.experimentalMatchedStyles.count, 0)
    XCTAssertEqual(reference4.referenced!.experimentalMatchedStyles.count, 4)
  }

  static var allTests = [
    ("testSingleWidget", testSingleWidget),
    ("testSingleWidgetInContainerWithStylesProcessChild", testSingleWidgetInContainerWithStylesProcessChild),
    ("testSingleWidgetInContainerWithStylesProcessRoot", testSingleWidgetInContainerWithStylesProcessRoot),
    ("testMultipleWidgetsInNestedContainersWithStylesProcessRoot", testMultipleWidgetsInNestedContainersWithStylesProcessRoot),
    ("testMultipleWidgetsInNestedContainersWithStylesProcessChild", testMultipleWidgetsInNestedContainersWithStylesProcessChild),
    ("testSingleWidgetWithNestedStyles", testSingleWidgetWithNestedStyles),
    ("testMultipleWidgetsInNestedContainersWithNestedStylesProcessRoot", testMultipleWidgetsInNestedContainersWithNestedStylesProcessRoot)
  ]
}