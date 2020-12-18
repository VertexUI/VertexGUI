import XCTest
import VisualAppBase
@testable import WidgetGUI

final class StyleTests: XCTestCase {
  func testStyleComparison() {
    let style1 = ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
      $0.fontSize = 30
      $0.foreground = .black
    }

    let style2 = ExperimentalText.Style(WidgetSelector(classes: ["class-2"])) {
      $0.fontSize = 30
      $0.foreground = .black
    }

    let style3 = ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
      $0.fontSize = 30
      $0.foreground = .black
    }

    let style4 = ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
      $0.fontSize = 31
    }

    let style5 = ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
      $0.foreground = .red
    }

    let style6 = ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
      $0.fontSize = 31
      $0.foreground = .red
    }

    let style7 = ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
      $0.fontSize = 31
      $0.foreground = .black
    }

    let style8 = ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
      $0.fontSize = 30
      $0.foreground = .black
      $0.fontWeight = .bold
    }

    let style9 = ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
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

  func testStyleSelectorAndOrderRespected() {
    let widget1 = ExperimentalText("Test1").with(classes: ["class-1"])
    let widget2 = ExperimentalText("Test2").with(classes: ["class-2"])
    let widget3 = Text("Test3").with(classes: ["class-2"])
    let widget4 = Text("Test4").with(classes: ["class-3"])
    let widget5 = ExperimentalText("Test5").with(classes: ["class-1", "class-2", "class-3"])
    let class2Style1 = ExperimentalText.Style(WidgetSelector(classes: ["class-2"])) {
      $0.foreground = .grey
    }
    let class2Style2 = ExperimentalText.Style(WidgetSelector(classes: ["class-2"])) {
      $0.fontWeight = .bold
    }
    let rootWidget = Column {
      widget1
      widget2
      widget3
      widget4
      widget5
    }.provideStyles {
      ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
        $0.fontSize = 50
      }
      ExperimentalText.Style {
        $0.fontWeight = .bold
      }
      class2Style1
      class2Style2
    }
    let mockRoot = MockRoot(rootWidget: rootWidget)

    // count should indicate that the selectors were respected
    XCTAssertEqual(rootWidget.appliedStyles.count, 1)
    XCTAssertEqual(widget1.appliedStyles.count, 2)
    XCTAssertEqual(widget2.appliedStyles.count, 3)
    XCTAssertEqual(widget3.appliedStyles.count, 3)
    XCTAssertEqual(widget4.appliedStyles.count, 1)
    XCTAssertEqual(widget5.appliedStyles.count, 4)

    // check order of styles
    XCTAssert(widget2.appliedStyles[1] == class2Style1)
    XCTAssert(widget2.appliedStyles[2] == class2Style2)
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
      ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
        $0.fontSize = 30
      }
      ExperimentalText.Style(WidgetSelector(classes: ["class-2"])) {
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
      ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
        $0.fontSize = 4
        $0.fontWeight = .black
      }
    }

    let widget3 = Column {
      widget2
    }.provideStyles {
      ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
        $0.fontSize = 3
        $0.fontWeight = .bold
      }
    }

    let widget4 = ExperimentalText("Text2").with(classes: ["class-1"])
    
    let widget5 = Column { 
      widget3
      widget4
    }.provideStyles {
      ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
        $0.fontSize = 1
      }
      ExperimentalText.Style(WidgetSelector(classes: ["class-1"])) {
        $0.fontSize = 2
      }
      ExperimentalText.Style(WidgetSelector(classes: ["class-2"])) {
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

  static var allTests = [
    ("testStyleComparison", testStyleComparison),
    ("testStyleOnDynamicallyInsertedWidget", testStyleOnDynamicallyInsertedWidget),
    ("testStyleSelectorAndOrderRespected", testStyleSelectorAndOrderRespected),
    ("testMultiParentStyleMergeOverwrite", testMultiParentStyleMergeOverwrite)
  ]
}