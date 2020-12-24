import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(MutablePropertyTests.allTests),
      testCase(StaticPropertyTests.allTests),
      testCase(ExperimentalMutablePropertyTests.allTests),
      testCase(UniDirectionalPropertyBindingTests.allTests),
    ]
  }
#endif
