import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(StyleSelectorTests.allTests),
      testCase(ExperimentalStyleTests.allTests),
      testCase(ExperimentalStylePropertySupportDefinitionsTests.allTests),
      testCase(ExperimentalStylePropertyTests.allTests),
      testCase(WidgetStyleScopeApplicationTests.allTests),
      testCase(ExperimentalStyleManagerTests.allTests),
      testCase(ExperimentalStylePropertiesResolverTests.allTests),
      testCase(ExperimentalWidgetStyleApiTests.allTests),
      testCase(ExperimentalWidgetTreeStyleTests.allTests),
      testCase(ExperimentalStyleParserTests.allTests),
      testCase(StylableWidgetTests.allTests),
      testCase(ReactivePropertyTests.allTests),
      testCase(BuildTests.allTests),
      testCase(ContainerTests.allTests)
    ]
  }
#endif
