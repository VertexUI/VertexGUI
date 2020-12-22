import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(MutablePropertyTests.allTests)
    ]
  }
#endif
