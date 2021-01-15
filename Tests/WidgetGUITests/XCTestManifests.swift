import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(FlexTests.allTests),
      testCase(StyleSelectorTests.allTests),
      testCase(StyleTests.allTests),
      testCase(ExperimentalStyleTests.allTests),
      testCase(ExperimentalStylePropertySupportDefinitionsTests.allTests),
      testCase(ExperimentalStylePropertyTests.allTests),
      testCase(ExperimentalWidgetStyleApiTests.allTests),
      testCase(ExperimentalStyleManagerTests.allTests),
      testCase(ExperimentalStyleParserTests.allTests),
      testCase(StylableWidgetTests.allTests),
      testCase(ReactivePropertyTests.allTests),
      testCase(BuildTests.allTests)
    ]
  }
#endif
