import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(MutablePropertyTests.allTests),
      testCase(ExperimentalReactivePropertyTests.allTests)
    ]
  }
#endif
