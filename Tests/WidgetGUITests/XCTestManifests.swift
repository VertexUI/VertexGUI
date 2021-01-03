import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(FlexTests.allTests),
      testCase(StyleTests.allTests),
      testCase(ReactivePropertyTests.allTests),
      testCase(BuildTests.allTests)
    ]
  }
#endif
