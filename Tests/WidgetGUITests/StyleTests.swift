import XCTest
import VisualAppBase
@testable import WidgetGUI

final class StyleTests: XCTestCase {
  func testStyleSelectorPartParsing() {
    var part: StyleSelectorPart = ".class1"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, ["class1"])
    XCTAssertEqual(part.pseudoClasses, [])
    
    part = ".class1.class2"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, ["class1", "class2"])
    XCTAssertEqual(part.pseudoClasses, [])

    part = ""
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, [])

    part = ":pseudoClass1"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, ["pseudoClass1"])

    part = ":pseudoClass1:pseudoClass2"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, ["pseudoClass1", "pseudoClass2"])

    part = ":pseudoClass1.class1"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.pseudoClasses, ["pseudoClass1"])
    XCTAssertEqual(part.classes, ["class1"])

    part = "&.class1:pseudoClass1.class2"
    XCTAssertTrue(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, ["class1", "class2"])
    XCTAssertEqual(part.pseudoClasses, ["pseudoClass1"])

    part = "&MockLeafWidget"
    XCTAssertTrue(part.extendsParent)
    XCTAssertEqual(part.typeName, "MockLeafWidget")
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, [])

    part = "MockLeafWidget"
    XCTAssertFalse(part.extendsParent)
    XCTAssertEqual(part.typeName, "MockLeafWidget")
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, [])

    part = "MockLeafWidget.class-1"
    XCTAssertFalse(part.extendsParent)
    XCTAssertEqual(part.typeName, "MockLeafWidget")
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, ["class-1"])
    XCTAssertEqual(part.pseudoClasses, [])
  }

  func testStyleSelectorParsing() {
    let selector: StyleSelector = ".class1 &.class2 Type1.class3:pseudoClass1"
    let parts: [StyleSelectorPart] = [".class1", "&.class2", "Type1.class3:pseudoClass1"]
    XCTAssertEqual(selector.parts, parts)
  }

  func testStyleSelectorComparison() {
    let selector1: StyleSelector = "&.class-1:pseudoClass-1"
    let selector2: StyleSelector = "&.class-1:pseudoClass-1"
    XCTAssertEqual(selector1, selector2)

    let selector3: StyleSelector = "&.class-1"
    XCTAssertNotEqual(selector1, selector3)

    let selector4: StyleSelector = "&.class-1:pseudoClass-1 &:pseudoClass-2"
    XCTAssertNotEqual(selector1, selector4)

    let selector5: StyleSelector = "&.class-1:pseudoClass-1 &:pseudoClass-2"
    XCTAssertEqual(selector4, selector5)

    let selector6: StyleSelector = "&Type1.class-1:pseudoClass-1 &:pseudoClass-2"
    XCTAssertNotEqual(selector5, selector6)

    let selector7: StyleSelector = "&Type1.class-1:pseudoClass-1 &:pseudoClass-2"
    XCTAssertEqual(selector6, selector7)

    let selector8: StyleSelector = "&Type1.class-1:pseudoClass-1 &:pseudoClass-2 &"
    XCTAssertNotEqual(selector7, selector8)

    let selector9: StyleSelector = ""
    let selector10: StyleSelector = ""
    XCTAssertEqual(selector9, selector10)

    let selector11: StyleSelector = ":pseudoClass-1"
    let selector12: StyleSelector = ":pseudoClass-1"
    let selector13: StyleSelector = ""
    XCTAssertEqual(selector11, selector12)
    XCTAssertNotEqual(selector11, selector13)

    let selector14: StyleSelector = "&"
    let selector15: StyleSelector = "&"
    let selector16: StyleSelector = ""
    XCTAssertEqual(selector14, selector15)
    XCTAssertNotEqual(selector14, selector16)

    let selector17: StyleSelector = ".class-1"
    let selector18: StyleSelector = ".class-1"
    let selector19: StyleSelector = ""
    let selector20: StyleSelector = ":pseudoClass-1"
    XCTAssertEqual(selector17, selector18)
    XCTAssertNotEqual(selector17, selector19)
    XCTAssertNotEqual(selector17, selector20)

    let selector21: StyleSelector = "Type1"
    let selector22: StyleSelector = "Type1"
    let selector23: StyleSelector = ""
    let selector24: StyleSelector = "&Type1"
    let selector25: StyleSelector = "Type2"
    let selector26: StyleSelector = "Type2.class-1"
    XCTAssertEqual(selector21, selector22)
    XCTAssertNotEqual(selector21, selector23)
    XCTAssertNotEqual(selector21, selector24)
    XCTAssertNotEqual(selector21, selector25)
    XCTAssertNotEqual(selector25, selector26)
  }

  func testStyleComparison() {
    let style1 = ExperimentalText.Style(".class-1") {
      $0.fontSize = 30
      $0.foreground = .black
    }

    let style2 = ExperimentalText.Style(".class-2") {
      $0.fontSize = 30
      $0.foreground = .black
    }

    let style3 = ExperimentalText.Style(".class-1") {
      $0.fontSize = 30
      $0.foreground = .black
    }

    let style4 = ExperimentalText.Style(".class-1") {
      $0.fontSize = 31
    }

    let style5 = ExperimentalText.Style(".class-1") {
      $0.foreground = .red
    }

    let style6 = ExperimentalText.Style(".class-1") {
      $0.fontSize = 31
      $0.foreground = .red
    }

    let style7 = ExperimentalText.Style(".class-1") {
      $0.fontSize = 31
      $0.foreground = .black
    }

    let style8 = ExperimentalText.Style(".class-1") {
      $0.fontSize = 30
      $0.foreground = .black
      $0.fontWeight = .bold
    }

    let style9 = ExperimentalText.Style(".class-1") {
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

    let style10 = MockLeafWidget.Style("&.class-1:pseudoClass-1") {
      $0.property1 = 1
    }

    let style11 = MockLeafWidget.Style("&.class-1:pseudoClass-1") {
      $0.property1 = 1
    }
 
    XCTAssertTrue(style10 == style11)
    
    let style12 = MockLeafWidget.Style("&.class-1:pseudoClass-1") {
      $0.property1 = 1
      $0.property2 = "1"
    }

    XCTAssertFalse(style10 == style12)

    let style13 = MockLeafWidget.Style("&.class-1 &Type1.class-2 &:pseudoClass-1") {
      $0.property3 = 1
    }

    let style14 = MockLeafWidget.Style("&.class-1 &Type1.class-2 &:pseudoClass-1") {
      $0.property3 = 1
    }

    XCTAssertTrue(style13 == style14)

    let style15 = MockLeafWidget.Style("&.class-1 .class-2 &") {
      $0.property3 = 1
    }

    XCTAssertFalse(style13 == style15)
  }

  func testSimpleSinglePartClassSelector() {
    let widget1 = MockLeafWidget().with(classes: ["class-1"])
    let widget2 = MockLeafWidget().with(classes: ["class-2"])
    let widget3 = MockLeafWidget().with(classes: ["class-2"])
    let widget4 = MockLeafWidget().with(classes: ["class-3"])
    let widget5 = MockLeafWidget().with(classes: ["class-1", "class-2", "class-3"])
    let class2Style1 = MockLeafWidget.Style(".class-2") {
      $0.property1 = 1
    }
    let class2Style2 = MockLeafWidget.Style(".class-2") {
      $0.property2 = "test1" 
    }
    let rootWidget = MockContainerWidget {
      widget1
      widget2
      widget3
      widget4
      widget5

      MockLeafWidget.Style(".class-1") {
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

  func testSimpleSinglePartPseudoClassSelector() {
    let widget = MockLeafWidget(state: .state2)
    let root = MockRoot(rootWidget: widget.provideStyles {
      MockLeafWidget.Style(":state2") {
        $0.property1 = 1
      }

      MockLeafWidget.Style(":state1") {
        $0.property1 = 2
      }

      MockLeafWidget.Style(":mode1") {
        $0.property3 = 1
      }

      MockLeafWidget.Style(":state2:mode1") {
        $0.property3 = 2
      }
    })
    XCTAssertEqual(widget.appliedStyles.count, 3)
  }

  func testSimpleTypeSelector() {
    let reference1 = Reference<MockLeafWidget>()
    let root = MockRoot(rootWidget: MockContainerWidget {
      MockLeafWidget().connect(ref: reference1)

      Style<MockSharedStyleProperties>("MockLeafWidget") {
        $0.property1 = 1
      }

      Style<MockSharedStyleProperties>("NonExistingWidget") {
        $0.property1 = 2
      }

      Style<MockSharedStyleProperties>(StyleSelector([StyleSelectorPart(type: MockLeafWidget.self)])) {
        $0.property1 = 3
      }
    })

    XCTAssertEqual(reference1.referenced!.appliedStyles.count, 2)
  }

  func testSimpleMultiPartSelector() {
    let reference1 = Reference<MockLeafWidget>()
    let root = MockRoot(rootWidget: MockContainerWidget {
      MockContainerWidget {
        MockContainerWidget {
          MockLeafWidget().with(classes: ["class-5", "class-6"]).connect(ref: reference1)
        }.with(classes: ["class-3", "class-4"])
      }.with(classes: ["class-2"])
    }.with(classes: ["class-1"]).provideStyles {
      MockLeafWidget.Style(".class-1 .class-2 .class-3 &.class-4 .class-5.class-6:state1 &MockLeafWidget:mode1") {
        $0.property1 = 1
      }
    })

    XCTAssertEqual(reference1.referenced!.appliedStyles.count, 1)
  }

  func testMultiPartClassSelectorWithGaps() {
    let reference1 = Reference<MockLeafWidget>()
    let root = MockRoot(rootWidget: MockContainerWidget {
      MockContainerWidget {
        MockContainerWidget {
          MockContainerWidget {
            MockContainerWidget {
              MockLeafWidget().with(classes: ["class-4"]).connect(ref: reference1)
            }.with(classes: ["ignored-class-2"])
          }.with(classes: ["class-3"])
        }.with(classes: ["class-2"])
      }.with(classes: ["ignored-class-1"])
    }.with(classes: ["class-1"]).provideStyles {
      MockLeafWidget.Style(".class-1 .class-2 .class-3 .class-4 &MockLeafWidget:state1:mode1") {
        $0.property1 = 1
      }
    })

    XCTAssertEqual(reference1.referenced!.appliedStyles.count, 1)
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
      ExperimentalText.Style(".class-1") {
        $0.fontSize = 30
      }
      ExperimentalText.Style(".class-2") {
        $0.fontWeight = .bold
      }
    }

    let mockRoot = MockRoot(rootWidget: rootWidget)

    XCTAssertEqual(widget1.appliedStyles.count, 1)
    XCTAssertEqual(widget2.appliedStyles.count, 0)

    showWidget2 = true

    rootWidget.invalidateBuild()
    mockRoot.mockTick()

    XCTAssertEqual(widget1.appliedStyles.count, 1)
    XCTAssertEqual(widget2.appliedStyles.count, 1)
  }

  func testMultiParentStyleMergeOverwrite() {
    let widget1 = ExperimentalText("Text1").with(classes: ["class-1", "class-2"])

    let widget2 = Column {
      widget1
    }.provideStyles {
      ExperimentalText.Style(".class-1") {
        $0.fontSize = 4
        $0.fontWeight = .black
      }
    }

    let widget3 = Column {
      widget2
    }.provideStyles {
      ExperimentalText.Style(".class-1") {
        $0.fontSize = 3
        $0.fontWeight = .bold
      }
    }

    let widget4 = ExperimentalText("Text2").with(classes: ["class-1"])
    
    let widget5 = Column { 
      widget3
      widget4
    }.provideStyles {
      ExperimentalText.Style(".class-1") {
        $0.fontSize = 1
      }
      ExperimentalText.Style(".class-1") {
        $0.fontSize = 2
      }
      ExperimentalText.Style(".class-2") {
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

  func testRootLevelStyleExtendsParentAppliedToContainingWidget() {
    let widget = MockLeafWidget()
    widget.provideStyles {
      MockLeafWidget.Style("&") {
        $0.property1 = 1
      }

      MockLeafWidget.Style("&MockLeafWidget") {
        $0.property1 = 1
      }
    }
    let root = MockRoot(rootWidget: widget)
    XCTAssertEqual(widget.appliedStyles.count, 2)
  }

  func testRootLevelStyleExtendsParentAppliedOnlyToContainingWidgetAndNotChildren() {
    let reference1 = Reference<MockContainerWidget>()
    let reference2 = Reference<MockContainerWidget>()
    let root = MockRoot(rootWidget: MockContainerWidget {
      MockContainerWidget.Style("&") {
        $0.property1 = 1
      }

      MockContainerWidget.Style("&MockContainerWidget") {
        $0.property1 = 1
      }

      MockContainerWidget {
      }.connect(ref: reference2)
    }.connect(ref: reference1))

    XCTAssertEqual(reference1.referenced!.appliedStyles.count, 2)
    XCTAssertEqual(reference2.referenced!.appliedStyles.count, 0)
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

    XCTAssertEqual(widget.filledStyleProperties.property1, 2)
  }

  func testComplexOverwritingSubStyles() {
    var reference1 = Reference<MockLeafWidget>()
    
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
      }.with(classes: ["container-class-1"])
      
      MockLeafWidget.Style(".container-class-1 & .class-1.class-2 &") {
        $0.property3 = 1
        $0.property4 = 1
      }
    })

    XCTAssertEqual(reference1.referenced!.filledStyleProperties.property1, 3)
    XCTAssertEqual(reference1.referenced!.filledStyleProperties.property2, "")
    XCTAssertEqual(reference1.referenced!.filledStyleProperties.property3, 1)
    XCTAssertEqual(reference1.referenced!.filledStyleProperties.property4, 2)
  }

  func testDynamicWidgetSelectorChange() {
    var widget = MockLeafWidget()
    widget.with(classes: ["class-1"]).provideStyles {
      MockLeafWidget.Style("MockLeafWidget") {
        $0.property1 = 1
      }

      MockLeafWidget.Style(":state1") {
        $0.property1 = 2
      }

      MockLeafWidget.Style(":mode2") {
        $0.property1 = 3
      }

      MockLeafWidget.Style(".class-1") {
        $0.property1 = 4
      }

      MockLeafWidget.Style(".class-2") {
        $0.property1 = 5
      }

      MockLeafWidget.Style(".class-3") {
        $0.property1 = 6
      }
    }
    let root = MockRoot(rootWidget: widget)

    XCTAssertEqual(widget.appliedStyles.count, 3)

    widget.classes = ["class-2", "class-3"]
    root.mockTick()
    
    XCTAssertEqual(widget.appliedStyles.count, 4)

    widget.mode = .mode2
    root.mockTick()

    XCTAssertEqual(widget.appliedStyles.count, 5)
  }

  static var allTests = [
    ("testStyleSelectorPartParsing", testStyleSelectorPartParsing),
    ("testStyleSelectorParsing", testStyleSelectorParsing),
    ("testStyleSelectorComparison", testStyleSelectorComparison),
    ("testStyleComparison", testStyleComparison),
    ("testSimpleSinglePartClassSelector", testSimpleSinglePartClassSelector),
    ("testSimpleSinglePartPseudoClassSelector", testSimpleSinglePartPseudoClassSelector),
    ("testSimpleTypeSelector", testSimpleTypeSelector),
    ("testSimpleMultiPartSelector", testSimpleMultiPartSelector),
    ("testMultiPartClassSelectorWithGaps", testMultiPartClassSelectorWithGaps),
    ("testEmptySelectorNonMatchingTypeIgnored", testEmptySelectorNonMatchingStyleTypeIgnored),
    ("testStyleOnDynamicallyInsertedWidget", testStyleOnDynamicallyInsertedWidget),
    ("testMultiParentStyleMergeOverwrite", testMultiParentStyleMergeOverwrite),
    ("testRootLevelStyleExtendsParentAppliedToContainingWidget", testRootLevelStyleExtendsParentAppliedToContainingWidget),
    ("testRootLevelStyleExtendsParentAppliedOnlyToContainingWidgetAndNotChildren", testRootLevelStyleExtendsParentAppliedOnlyToContainingWidgetAndNotChildren),
    ("testSimpleSubStyles", testSimpleSubStyles),
    ("testSimpleOverwritingSubStyles", testSimpleOverwritingSubStyles),
    ("testComplexOverwritingSubStyles", testComplexOverwritingSubStyles),
    ("testDynamicWidgetSelectorChange", testDynamicWidgetSelectorChange)
  ]

  struct MockSharedStyleProperties: StyleProperties {
    @StyleProperty
    var property1: Double?

    init() {}
  }
}