import XCTest
import VisualAppBase
@testable import WidgetGUI

final class StyleTests: XCTestCase {
  func testStyleSelectorParsing() {
    var selector: StyleSelector = ".class1"
    XCTAssertEqual(selector.classes, ["class1"])
    selector = ".class1.class2"
    XCTAssertEqual(selector.classes, ["class1", "class2"])
    selector = ""
    XCTAssertEqual(selector.classes, [])
    selector = ":pseudoClass1"
    XCTAssertEqual(selector.pseudoClasses, ["pseudoClass1"])
    selector = ":pseudoClass1:pseudoClass2"
    XCTAssertEqual(selector.pseudoClasses, ["pseudoClass1", "pseudoClass2"])
    selector = ":pseudoClass1.class1"
    XCTAssertEqual(selector.pseudoClasses, ["pseudoClass1"])
    XCTAssertEqual(selector.classes, ["class1"])
  }

  func testStyleComparison() {
    let style1 = ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
      $0.fontSize = 30
      $0.foreground = .black
    }

    let style2 = ExperimentalText.Style(StyleSelector(classes: ["class-2"])) {
      $0.fontSize = 30
      $0.foreground = .black
    }

    let style3 = ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
      $0.fontSize = 30
      $0.foreground = .black
    }

    let style4 = ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
      $0.fontSize = 31
    }

    let style5 = ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
      $0.foreground = .red
    }

    let style6 = ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
      $0.fontSize = 31
      $0.foreground = .red
    }

    let style7 = ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
      $0.fontSize = 31
      $0.foreground = .black
    }

    let style8 = ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
      $0.fontSize = 30
      $0.foreground = .black
      $0.fontWeight = .bold
    }

    let style9 = ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
      $0.fontWeight = .bold
    }

    XCTAssertTrue(style1 != style2)
    XCTAssertTrue(style1 == style3)
    XCTAssertFalse(style1 == style4)
    XCTAssertFalse(style1 == style5)
    XCTAssertFalse(style1 == style6)
    XCTAssertFalse(style1 == style7)
    XCTAssertFalse(style1 == style8)
    XCTAssertFalse(style1 == style9)
  }

  func testSimpleClassSelector() {
    let widget1 = MockLeafWidget().with(classes: ["class-1"])
    let widget2 = MockLeafWidget().with(classes: ["class-2"])
    let widget3 = MockLeafWidget().with(classes: ["class-2"])
    let widget4 = MockLeafWidget().with(classes: ["class-3"])
    let widget5 = MockLeafWidget().with(classes: ["class-1", "class-2", "class-3"])
    let class2Style1 = MockLeafWidget.Style(StyleSelector(classes: ["class-2"])) {
      $0.property1 = 1
    }
    let class2Style2 = MockLeafWidget.Style(StyleSelector(classes: ["class-2"])) {
      $0.property2 = "test1" 
    }
    let rootWidget = MockContainerWidget {
      widget1
      widget2
      widget3
      widget4
      widget5

      MockLeafWidget.Style(StyleSelector(classes: ["class-1"])) {
        $0.property1 = 2
      }
      MockLeafWidget.Style {
        $0.property2 = "test2"
      }
      class2Style1
      class2Style2
    }
    let mockRoot = MockRoot(rootWidget: rootWidget)

    // count should indicate that the selectors were respected
    XCTAssertEqual(rootWidget.appliedStyles.count, 0)
    XCTAssertEqual(widget1.appliedStyles.count, 2)
    XCTAssertEqual(widget2.appliedStyles.count, 3)
    XCTAssertEqual(widget3.appliedStyles.count, 3)
    XCTAssertEqual(widget4.appliedStyles.count, 1)
    XCTAssertEqual(widget5.appliedStyles.count, 4)

    // check order of styles
    XCTAssert(widget2.appliedStyles[1] == class2Style1)
    XCTAssert(widget2.appliedStyles[2] == class2Style2)
  }

  func testEmptySelectorNonMatchingStyleTypeIgnored() {
    let reference1 = Reference<MockLeafWidget>()
    let reference2 = Reference<MockContainerWidget>()
    let root = MockRoot(rootWidget: MockContainerWidget {
      MockLeafWidget().with(classes: ["class-1"]).connect(ref: reference1)
      MockContainerWidget() {}.with(classes: ["class-1"]).connect(ref: reference2)
    }.provideStyles {
      MockLeafWidget.Style {
        $0.property1 = 1
      }
    })

    XCTAssertEqual(reference1.referenced!.appliedStyles.count, 1)
    XCTAssertEqual(reference2.referenced!.appliedStyles.count, 0)
  }

  func testStyleOnDynamicallyInsertedWidget() {
    let widget1 = ExperimentalText("Text1").with(classes: ["class-1"])
    let widget2 = ExperimentalText("Text2").with(classes: ["class-2"])

    var showWidget2 = false

    let rootWidget = Column {
      widget1
      if showWidget2 {
        widget2
      }
    }.provideStyles {
      ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
        $0.fontSize = 30
      }
      ExperimentalText.Style(StyleSelector(classes: ["class-2"])) {
        $0.fontWeight = .bold
      }
    }

    let mockRoot = MockRoot(rootWidget: rootWidget)

    XCTAssertEqual(widget1.appliedStyles.count, 1)
    XCTAssertEqual(widget2.appliedStyles.count, 0)

    showWidget2 = true

    rootWidget.invalidateBuild()
    mockRoot.tick(Tick(deltaTime: 0, totalTime: 0))

    XCTAssertEqual(widget1.appliedStyles.count, 1)
    XCTAssertEqual(widget2.appliedStyles.count, 1)
  }

  func testMultiParentStyleMergeOverwrite() {
    let widget1 = ExperimentalText("Text1").with(classes: ["class-1", "class-2"])

    let widget2 = Column {
      widget1
    }.provideStyles {
      ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
        $0.fontSize = 4
        $0.fontWeight = .black
      }
    }

    let widget3 = Column {
      widget2
    }.provideStyles {
      ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
        $0.fontSize = 3
        $0.fontWeight = .bold
      }
    }

    let widget4 = ExperimentalText("Text2").with(classes: ["class-1"])
    
    let widget5 = Column { 
      widget3
      widget4
    }.provideStyles {
      ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
        $0.fontSize = 1
      }
      ExperimentalText.Style(StyleSelector(classes: ["class-1"])) {
        $0.fontSize = 2
      }
      ExperimentalText.Style(StyleSelector(classes: ["class-2"])) {
        $0.fontWeight = .medium
      }
    }
    
    let mockRoot = MockRoot(rootWidget: widget5)

    XCTAssertEqual(widget4.appliedStyles.count, 2)
    XCTAssertEqual(widget4.filledStyleProperties.fontSize, 2)
    XCTAssertEqual(widget1.appliedStyles.count, 5)
    XCTAssertEqual(widget1.filledStyleProperties.fontSize, 4)
    XCTAssertEqual(widget1.filledStyleProperties.fontWeight, .black)
  }

  func testSimpleSubStyles() {
    let widget1 = ExperimentalText("Text1").with(classes: ["class-1"])
    let rootWidget = Column {
      widget1
    }.provideStyles {
      ExperimentalText.Style(".class-1") {
        $0.fontSize = 1

        ExperimentalText.Style() {
          $0.fontSize = 1
        }
      }
    }
    let root = MockRoot(rootWidget: rootWidget)
    XCTAssertEqual(widget1.appliedStyles.count, 1)
  }

  func testSimpleOverwritingSubStyles() {
    let widget = MockLeafWidget()
    widget.with(classes: ["class-1", "class-2"]).provideStyles {
      MockLeafWidget.Style(".class-1") {
        $0.property1 = 1

        MockLeafWidget.Style("&.class-1") {
          $0.property1 = 2

          MockLeafWidget.Style {
            $0.property1 = 3

            MockLeafWidget.Style("&") {
              $0.property1 = 4
            }
          }
        }
      }
    }
    let root = MockRoot(rootWidget: widget)

    XCTAssertEqual(widget.filledStyleProperties.property1, 4)
  }

  func testComplexOverwritingSubStyles() {
    var reference1 = Reference<MockLeafWidget>()
    let reference2 = Reference<MockContainerWidget>()
    
    let root = MockRoot(rootWidget: MockContainerWidget {
      MockContainerWidget {
        MockContainerWidget {
          MockLeafWidget().with(classes: ["class-1", "class-2"]).connect(ref: reference1)

          MockLeafWidget.Style(".class-1") {
            $0.property1 = 1

            MockLeafWidget.Style("&") {
              $0.property1 = 2
            }

            MockLeafWidget.Style("&.class-2") {
              $0.property1 = 3
              MockLeafWidget.Style("&") {
                $0.property4 = 2
              }
            }
          }
        }
      }.with(classes: ["container-class-1"]).connect(ref: reference2)
      
      // and some crazy nesting and backreferencing
      MockContainerWidget.Style(".container-class-1") {
        MockContainerWidget.Style("&") { 
          MockLeafWidget.Style(".class-1.class-2") { 
            MockLeafWidget.Style("&") {
              $0.property3 = 1
              $0.property4 = 1
            }
          }
        }
      }
    })

    XCTAssertEqual(reference1.referenced!.filledStyleProperties.property1, 3)
    XCTAssertEqual(reference1.referenced!.filledStyleProperties.property2, "")
    XCTAssertEqual(reference1.referenced!.filledStyleProperties.property3, 1)
    XCTAssertEqual(reference1.referenced!.filledStyleProperties.property4, 2)
    XCTAssertEqual(reference2.referenced!.appliedStyles.count, 2)
  }

  static var allTests = [
    ("testStyleSelectorParsing", testStyleSelectorParsing),
    ("testStyleComparison", testStyleComparison),
    ("testSimpleClassSelector", testSimpleClassSelector),
    ("testEmptySelectorNonMatchingTypeIgnored", testEmptySelectorNonMatchingStyleTypeIgnored),
    ("testStyleOnDynamicallyInsertedWidget", testStyleOnDynamicallyInsertedWidget),
    ("testMultiParentStyleMergeOverwrite", testMultiParentStyleMergeOverwrite),
    ("testSimpleSubStyles", testSimpleSubStyles),
    ("testSimpleOverwritingSubStyles", testSimpleOverwritingSubStyles),
    ("testComplexOverwritingSubStyles", testComplexOverwritingSubStyles),
  ]
}