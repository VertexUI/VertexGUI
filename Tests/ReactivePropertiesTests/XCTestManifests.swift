import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(StaticPropertyTests.allTests),
      testCase(MutablePropertyTests.allTests),
      testCase(ComputedPropertyTests.allTests),
      testCase(MutableComputedPropertyTests.allTests),
      testCase(ObservablePropertyTests.allTests),
      testCase(UniDirectionalPropertyBindingTests.allTests),
      testCase(BiDirectionalPropertyBindingTests.allTests),
      testCase(DependencyRecorderTests.allTests)
    ]
  }
#endif
