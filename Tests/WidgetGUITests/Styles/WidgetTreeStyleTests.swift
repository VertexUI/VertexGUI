import XCTest
import GfxMath
@testable import WidgetGUI

class WidgetTreeStyleTests: XCTestCase {
  class TestWidget: Widget, StylableWidgetProtocol {
    var buildInternal: ((MultiChildContentBuilder.ChildrenBuilder?) -> [Widget])?
    var childrenBuilder: MultiChildContentBuilder.ChildrenBuilder?

    var pseudoClass1Enabled: Bool = false {
      didSet {
        if pseudoClass1Enabled {
          enablePseudoClass(PseudoClasses.pseudoClass1)
        } else {
          disablePseudoClass(PseudoClasses.pseudoClass1)
        }
      }
    }

    init(_ createsStyleScope: Bool, buildInternal: ((MultiChildContentBuilder.ChildrenBuilder?) -> [Widget])?,
      @MultiChildContentBuilder content buildContent: () -> MultiChildContentBuilder.Result) {
        self.buildInternal = buildInternal
        let content = buildContent()
        self.childrenBuilder = content.childrenBuilder
        super.init()
        self.createsStyleScope = createsStyleScope
        self.provideStyles(content.styles)
    }

    init(_ createsStyleScope: Bool) {
      self.buildInternal = nil
      self.childrenBuilder = nil
      super.init()
      self.createsStyleScope = createsStyleScope
    }

    override func performBuild() {
      if let buildInternal = buildInternal {
        children = buildInternal(self.childrenBuilder)
      } else if let childrenBuilder = childrenBuilder {
        children = childrenBuilder()
      }
    }

    enum StyleKeys: String, StyleKey, DefaultStyleKeys {
      case property1
      case property2
    }

    enum PseudoClasses: String, PseudoClass {
      case pseudoClass1 
    }
  }

  func testSimpleOneWidget() {
    let widget = TestWidget(true)
    widget.provideStyles([
      Style("&", TestWidget.self) {
        ($0.property1, 2.0)
      }
    ])
    let root = MockRoot(rootWidget: widget)

    XCTAssertEqual(widget.stylePropertyValue(TestWidget.StyleKeys.property1) as? Double, 2.0)
  }

  func testOneWidgetWithReactiveInputOutput() {
    let widget = TestWidget(true)
    let inputProperty = MutableProperty<Double>()
    widget.provideStyles([
      Style("&", TestWidget.self) {
        ($0.property1, inputProperty)
      }
    ])
    let root = MockRoot(rootWidget: widget)
    let outputProperty: ObservableProperty<Double?> = widget.stylePropertyValue(reactive: TestWidget.StyleKeys.property1)

    XCTAssertEqual(outputProperty.value, nil)

    inputProperty.value = 1.0
    XCTAssertEqual(outputProperty.value, 1.0)
  }

  func testFullTree() {
    let reference1 = Reference<TestWidget>()
    let reference2 = Reference<TestWidget>()
    let reference3 = Reference<TestWidget>()
    let reference4 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: TestWidget(false, buildInternal: nil) {
      Style(".class-1", TestWidget.self) {
        ($0.property1, 1.0)
        ($0.property2, -1.0)
      }

      Style(".class-3", TestWidget.self) {
        ($0.property1, 2.0)
        ($0.property2, -2.0)
      }

      Style(".class-7", TestWidget.self) {
        ($0.property2, -7.0)
      }

      TestWidget(true, buildInternal: {
        ($0?() ?? []) + [
          TestWidget(true, buildInternal: nil) {
            Style(".class-1", TestWidget.self) {
              ($0.property2, -4.0)
            }

            Style(".class-3", TestWidget.self) {
              ($0.property2, 8.0)
            }

            TestWidget(true).with(classes: ["class-1"]).connect(ref: reference1)
          }.with(classes: ["class-2"]).connect(ref: reference2)
        ]
      }) {
        Style("&.class-7", TestWidget.self) {
          ($0.property2, -6.0)

          Style("&< .class-2", TestWidget.self) {
            ($0.property1, 5.0)
          }

          Style(".class-3", TestWidget.self) {
            ($0.property1, 3.0)
          }
        }

        TestWidget(false).with(classes: ["class-3"]).connect(ref: reference4)
      }.with(classes: ["class-7"]).connect(ref: reference3)
    })

    XCTAssertEqual(reference1.referenced!.stylePropertyValue(TestWidget.StyleKeys.property1) as? Double, nil)
    XCTAssertEqual(reference1.referenced!.stylePropertyValue(TestWidget.StyleKeys.property2) as? Double, -4.0)
    XCTAssertEqual(reference2.referenced!.stylePropertyValue(TestWidget.StyleKeys.property1) as? Double, 5.0)
    XCTAssertEqual(reference3.referenced!.stylePropertyValue(TestWidget.StyleKeys.property2) as? Double, -6.0)
    XCTAssertEqual(reference4.referenced!.stylePropertyValue(TestWidget.StyleKeys.property1) as? Double, 3.0)
    XCTAssertEqual(reference4.referenced!.stylePropertyValue(TestWidget.StyleKeys.property2) as? Double, -2.0)
  }

  func testSimpleRealWidgets() {
    let reference1 = Reference<Button>()
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: nil) {
      Style(".button", Button.self) {
        ($0.background, Color.red)
      }

      Button() {
        Text("test")
      }.with(classes: ["button"]).connect(ref: reference1)
    })

    XCTAssertEqual(reference1.referenced!.stylePropertyValue(Button.StyleKeys.background) as? Color, Color.red)
  }

  func testPseudoClassUpdate() {
    let reference1 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: nil) {
      Style(".class-1", TestWidget.self) {
        ($0.property1, 1.0)
      }

      Style(".class-1:pseudoClass1", TestWidget.self) {
        ($0.property1, 2.0)
      }

      TestWidget(true).with(classes: ["class-1"]).connect(ref: reference1)
    })

    XCTAssertEqual(reference1.referenced!.stylePropertyValue(TestWidget.StyleKeys.property1) as? Double, 1.0)

    reference1.referenced!.pseudoClass1Enabled = true
    root.tick()
    XCTAssertEqual(reference1.referenced!.stylePropertyValue(TestWidget.StyleKeys.property1) as? Double, 2.0)

    reference1.referenced!.pseudoClass1Enabled = false
    root.tick()
    XCTAssertEqual(reference1.referenced!.stylePropertyValue(TestWidget.StyleKeys.property1) as? Double, 1.0)
  }

  func testPropertyValueInherit() {
    let reference1 = Reference<TestWidget>()
    let reference2 = Reference<TestWidget>()
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: nil) {
      Style(".class-1", TestWidget.self) {
        ($0.property1, 1.0)
        ($0.property2, 2.0)
      }

      TestWidget(true, buildInternal: nil) {
        TestWidget(true).with(styleProperties: {
          ($0.property1, .inherit)
        }).connect(ref: reference2)
      }.with(classes: ["class-1"]).connect(ref: reference1)
    })

    XCTAssertEqual(reference1.referenced!.stylePropertyValue(TestWidget.StyleKeys.property1) as? Double, 1.0)
    XCTAssertEqual(reference2.referenced!.stylePropertyValue(TestWidget.StyleKeys.property1) as? Double, 1.0)
    XCTAssertNil(reference2.referenced!.stylePropertyValue(TestWidget.StyleKeys.property2))
  }

  func testPropertyValueInheritReactive() {
    let reference1 = Reference<TestWidget>()
    let reference2 = Reference<TestWidget>()
    let inputProperty1 = MutableProperty<StyleValue>()
    let inputProperty2 = MutableProperty<StyleValue>()
    let root = MockRoot(rootWidget: TestWidget(true, buildInternal: nil) {
      Style(".class-1", TestWidget.self) {
        ($0.property1, inputProperty1)
      }

      TestWidget(true, buildInternal: nil) {
        TestWidget(true).with(styleProperties: {
          ($0.property1, inputProperty2)
        }).connect(ref: reference2)
      }.with(classes: ["class-1"]).connect(ref: reference1)
    })
    let outputProperty = reference2.referenced!.stylePropertyValue(reactive: TestWidget.StyleKeys.property1)

    inputProperty1.value = "test"
    inputProperty2.value = SpecialStyleValue.inherit
    XCTAssertEqual(reference1.referenced!.stylePropertyValue(TestWidget.StyleKeys.property1) as? String, "test")
    XCTAssertEqual(outputProperty.value as? String, "test")
  }

  static var allTests = [
    ("testSimpleOneWidget", testSimpleOneWidget),
    ("testOneWidgetWithReactiveInputOutput", testOneWidgetWithReactiveInputOutput),
    ("testFullTree", testFullTree),
    ("testSimpleRealWidgets", testSimpleRealWidgets),
    ("testPseudoClassUpdate", testPseudoClassUpdate),
    ("testPropertyValueInherit", testPropertyValueInherit),
    ("testPropertyValueInheritReactive", testPropertyValueInheritReactive)
  ]
}