import XCTest

//import swift_gui_demo_appTests
import VisualAppBaseTests
import WidgetGUITests

var tests = [XCTestCaseEntry]()
//tests += swift_gui_demo_appTests.allTests()
tests += VisualAppBaseTests.allTests()
tests += WidgetGUITests.allTests()
XCTMain(tests)
