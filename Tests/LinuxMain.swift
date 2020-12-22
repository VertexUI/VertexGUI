import XCTest

import VisualAppBaseTests
import WidgetGUITests
import ReactivePropertiesTests

var tests = [XCTestCaseEntry]()
tests += VisualAppBaseTests.allTests()
tests += WidgetGUITests.allTests()
tests += ReactivePropertiesTests.allTests()
XCTMain(tests)
