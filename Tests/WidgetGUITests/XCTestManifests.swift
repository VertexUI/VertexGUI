import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(StyleSelectorTests.allTests),
      testCase(StyleTests.allTests),
      testCase(StylePropertySupportDefinitionsTests.allTests),
      testCase(StylePropertyTests.allTests),
      testCase(WidgetStyleScopeApplicationTests.allTests),
      testCase(StyleManagerTests.allTests),
      testCase(StylePropertiesResolverTests.allTests),
      testCase(WidgetStyleApiTests.allTests),
      testCase(WidgetTreeStyleTests.allTests),
      testCase(StyleParserTests.allTests),
      testCase(StylableWidgetProtocolTests.allTests),
      testCase(ReactivePropertyTests.allTests),
      testCase(BuildTests.allTests),
      testCase(ContainerTests.allTests)
    ]
  }
#endif
