import XCTest
import VisualAppBase
import GfxMath
@testable import WidgetGUI

class StyleManagerTests: XCTestCase {
  class TestWidget: Widget, StylableWidget {
    enum StyleKeys: String, StyleKey, DefaultStyleKeys {
      case specificProperty1
    }
  }

  class ScopeTestWidget: Widget, StylableWidget {
    private let buildInternal: ((MultiChildContentBuilder.ChildrenBuilder?) -> [Widget])?
    private let childrenBuilder: MultiChildContentBuilder.ChildrenBuilder?

    init(_ createsStyleScope: Bool, buildInternal: ((MultiChildContentBuilder.ChildrenBuilder?) -> [Widget])?, @MultiChildContentBuilder content buildContent: () -> MultiChildContentBuilder.Result) {
      let content = buildContent()
      self.childrenBuilder = content.childrenBuilder
      self.buildInternal = buildInternal 
      super.init()
      self.createsStyleScope = createsStyleScope
      self.providedStyles.append(contentsOf: content.styles)
    }

    init(_ createsStyleScope: Bool, buildInternal: @escaping (MultiChildContentBuilder.ChildrenBuilder?) -> [Widget]) {
      self.buildInternal = buildInternal
      self.childrenBuilder = nil
      super.init()
      self.createsStyleScope = createsStyleScope
    }

    init(_ createsStyleScope: Bool) {
      self.buildInternal = nil
      self.childrenBuilder = nil
      super.init()
      self.createsStyleScope = createsStyleScope
    }

    override func performBuild() {
      if let buildInternal = self.buildInternal {
        children = buildInternal(self.childrenBuilder)
      } else if let childrenBuilder = self.childrenBuilder {
        children = childrenBuilder()
      }
    }
  }

  class MockRoot: Root {
    override public init(rootWidget: Widget) {
      super.init(rootWidget: rootWidget)
      self.setup(
        window: try! Window(options: Window.Options()),
        getTextBoundsSize: { _, _, _ in DSize2.zero },
        measureText: { _, _ in .zero },
        getKeyStates: { KeyStatesContainer() },
        getApplicationTime: { 0 },
        getRealFps: { 0 },
        createWindow: { _, _ in try! Window(options: Window.Options()) },
        requestCursor: { _ in {} } )
    }
    
    override open func setup(
      window: Window,
      getTextBoundsSize: @escaping (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2,
      measureText: @escaping (_ text: String, _ paint: TextPaint) -> DSize2,
      getKeyStates: @escaping () -> KeyStatesContainer,
      getApplicationTime: @escaping () -> Double,
      getRealFps: @escaping () -> Double,
      createWindow: @escaping (_ guiRootBuilder: @autoclosure () -> Root, _ options: Window.Options) -> Window,
      requestCursor: @escaping (_ cursor: Cursor) -> () -> Void
    ) {
      self.widgetContext = WidgetContext(
        window: window,
        getTextBoundsSize: getTextBoundsSize,
        measureText: measureText,
        getKeyStates: getKeyStates,
        getApplicationTime: getApplicationTime,
        getRealFps: getRealFps,
        createWindow: createWindow,
        requestCursor: requestCursor,
        queueLifecycleMethodInvocation: { [unowned self] in widgetLifecycleManager.queue($0, target: $1, sender: $2, reason: $3) },
        lifecycleMethodInvocationSignalBus: Bus<Widget.LifecycleMethodInvocationSignal>(),
        globalStylePropertySupportDefinitions: []
      )
      rootWidget.mount(parent: self, treePath: [], context: widgetContext!, lifecycleBus: widgetLifecycleBus)
    }

    public func tick() {
      tick(Tick(deltaTime: 0, totalTime: 0))
    }
  }

  func testSingleWidget() {
    let widget = TestWidget()
    widget.provideStyles([
      Style("", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      },
      Style("&", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      }
    ])
    let root = MockRoot(rootWidget: widget)
    let styleManager = StyleManager()

    styleManager.processTree(widget)
    XCTAssertEqual(widget.matchedStyles.count, 1)
  }

  func testSingleWidgetInContainerWithStylesProcessChild() {
    let widget = TestWidget()
    let container = Container().withContent {
      Style("", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      }

      widget
    }
    let root = MockRoot(rootWidget: container)
    let styleManager = StyleManager()

    styleManager.processTree(widget)
    XCTAssertEqual(container.matchedStyles.count, 0)
    XCTAssertEqual(widget.matchedStyles.count, 1)
  }

  func testSingleWidgetInContainerWithStylesProcessRoot() {
    let widget = TestWidget()
    let container = Container().withContent {
      Style("&", Container.self) {
        ($0.foreground, 1.0)
      }

      Style(".child", TestWidget.self) {
        ($0.specificProperty1, 1.0)
      }

      widget.with(classes: ["child"])
    }
    let root = MockRoot(rootWidget: container)
    let styleManager = StyleManager()

    styleManager.processTree(container)
    XCTAssertEqual(container.matchedStyles.count, 1)
    XCTAssertEqual(widget.matchedStyles.count, 1)
  }

  func testMultipleWidgetsInNestedContainersWithStylesProcessRoot() {
    let reference1 = Reference<Container>()
    let reference2 = Reference<Container>()
    let reference3 = Reference<Container>()
    let reference4 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: Container().withContent {
      Style("&") {}

      Container(classes: ["class-1"]) {
        Style("&.class-1") {}
        Style(".class-1") {}

        Container(classes: ["class-2"]) {
          Style(".class-1") {}

          TestWidget().with(classes: ["class-1"]).connect(ref: reference4)
        }.connect(ref: reference3)
      }.connect(ref: reference2)
    }.connect(ref: reference1))
    let styleManager = StyleManager()
    styleManager.processTree(root.rootWidget)

    XCTAssertEqual(reference1.referenced!.matchedStyles.count, 1)
    XCTAssertEqual(reference2.referenced!.matchedStyles.count, 1)
    XCTAssertEqual(reference3.referenced!.matchedStyles.count, 0)
    XCTAssertEqual(reference4.referenced!.matchedStyles.count, 2)
  }

  func testMultipleWidgetsInNestedContainersWithStylesProcessChild() {
    let reference1 = Reference<Container>()
    let reference2 = Reference<Container>()
    let reference3 = Reference<Container>()
    let reference4 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: Container().withContent {
      Style("&") {}

      Container(classes: ["class-1"]) {
        Style("&.class-1") {}
        Style(".class-1") {}

        Container(classes: ["class-2"]) {
          Style(".class-1") {}

          TestWidget().with(classes: ["class-1"]).connect(ref: reference4)
        }.connect(ref: reference3)
      }.connect(ref: reference2)
    }.connect(ref: reference1))
    let styleManager = StyleManager()
    styleManager.processTree(reference4.referenced!)

    XCTAssertEqual(reference1.referenced!.matchedStyles.count, 0)
    XCTAssertEqual(reference2.referenced!.matchedStyles.count, 0)
    XCTAssertEqual(reference3.referenced!.matchedStyles.count, 0)
    XCTAssertEqual(reference4.referenced!.matchedStyles.count, 2)
  }

  func testSingleWidgetWithNestedStyles() {
    let widget = TestWidget()
    widget.with(classes: ["class-1"])
    widget.provideStyles([
      Style("&") {
        Style("&") {
          Style("&.class-1") {}

          Style("&") {}

          // should not match
          Style("") {}
        }
        
        // should not match
        Style(".class-1") {}
      }
    ])
    let styleManager = StyleManager()

    styleManager.processTree(widget)
    XCTAssertEqual(widget.matchedStyles.count, 4)
  }

  func testMultipleWidgetsInNestedContainersWithNestedStylesProcessRoot() {
    let reference1 = Reference<Container>()
    let reference2 = Reference<Container>()
    let reference3 = Reference<Container>()
    let reference4 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: Container().withContent {
      Style("&") {
        Style("&.class-1") {}
        Style(".class-1") {}
      }

      Container(classes: ["class-1"]) {
        Style("& &.class-1") {
          Style(".class-1") {}
        }

        Container(classes: ["class-2"]) {
          Style(".class-1") {
            Style("&.class-1") {}
          }

          TestWidget().with(classes: ["class-1"]).connect(ref: reference4)
        }.connect(ref: reference3)
      }.connect(ref: reference2)
    }.connect(ref: reference1))
    let styleManager = StyleManager()
    styleManager.processTree(root.rootWidget)

    XCTAssertEqual(reference1.referenced!.matchedStyles.count, 1)
    XCTAssertEqual(reference2.referenced!.matchedStyles.count, 2)
    XCTAssertEqual(reference3.referenced!.matchedStyles.count, 0)
    XCTAssertEqual(reference4.referenced!.matchedStyles.count, 4)
  }

  func testSimpleScoping() {
    let reference1 = Reference<ScopeTestWidget>()
    let reference2 = Reference<ScopeTestWidget>()
    let reference3 = Reference<ScopeTestWidget>()
    let root = MockRoot(rootWidget: ScopeTestWidget(true, buildInternal: nil) {
      Style("&") {
        Style(".class-3") {}
      }
      Style(".class-1") {}

      ScopeTestWidget(true, buildInternal: { _ in
        [
          ScopeTestWidget(true, buildInternal: nil) {
            Style("&.class-2") {}
          }.with(classes: ["class-1", "class-2"]).connect(ref: reference3)
        ]
      }).provideStyles([
        Style(".class-2") {}
      ]).with(classes: ["class-3"]).connect(ref: reference2)
    }.connect(ref: reference1))
    let styleManager = StyleManager()

    styleManager.processTree(root.rootWidget)
    XCTAssertEqual(reference1.referenced!.matchedStyles.count, 1)
    XCTAssertEqual(reference2.referenced!.matchedStyles.count, 1)
    XCTAssertEqual(reference3.referenced!.styleScope, reference2.referenced!.id)
    XCTAssertEqual(reference3.referenced!.matchedStyles.count, 1)
  }

  func testComplexScoping() {
    let reference1 = Reference<ScopeTestWidget>()
    let reference2 = Reference<ScopeTestWidget>()
    let reference3 = Reference<ScopeTestWidget>()
    let reference4 = Reference<ScopeTestWidget>()
    let root = MockRoot(rootWidget: ScopeTestWidget(true, buildInternal: {
      $0!() + [
        ScopeTestWidget(true, buildInternal: nil) {
          Style("&.class-1") {
            Style("& .class-2") {}
          }

          ScopeTestWidget(true).with(classes: ["class-2"]).connect(ref: reference4)
        }.with(classes: ["class-1"]).connect(ref: reference3)
      ]
    }) {
      Style("& &<") {
        Style("&.class-0") {}

        Style(".class-3") {}

        Style(".class-1") {
          Style(".class-2") {}
        }
      }

      Style("&") {
        Style(".class-1") {}

        Style(".class-3") {}
      }

      ScopeTestWidget(true).with(classes: ["class-3"]).connect(ref: reference2)
    }.with(classes: ["class-0"]).connect(ref: reference1))
    let styleManager = StyleManager()

    styleManager.processTree(root.rootWidget)
    XCTAssertEqual(reference1.referenced!.matchedStyles.count, 3)
    XCTAssertEqual(reference2.referenced!.matchedStyles.count, 2)
    XCTAssertEqual(reference3.referenced!.matchedStyles.count, 2)
    XCTAssertEqual(reference4.referenced!.matchedStyles.count, 2)
  }

  static var allTests = [
    ("testSingleWidget", testSingleWidget),
    ("testSingleWidgetInContainerWithStylesProcessChild", testSingleWidgetInContainerWithStylesProcessChild),
    ("testSingleWidgetInContainerWithStylesProcessRoot", testSingleWidgetInContainerWithStylesProcessRoot),
    ("testMultipleWidgetsInNestedContainersWithStylesProcessRoot", testMultipleWidgetsInNestedContainersWithStylesProcessRoot),
    ("testMultipleWidgetsInNestedContainersWithStylesProcessChild", testMultipleWidgetsInNestedContainersWithStylesProcessChild),
    ("testSingleWidgetWithNestedStyles", testSingleWidgetWithNestedStyles),
    ("testMultipleWidgetsInNestedContainersWithNestedStylesProcessRoot", testMultipleWidgetsInNestedContainersWithNestedStylesProcessRoot),
    ("testSimpleScoping", testSimpleScoping),
    ("testComplexScoping", testComplexScoping)
  ]
}