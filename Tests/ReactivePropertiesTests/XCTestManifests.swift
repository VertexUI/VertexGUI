import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(StaticPropertyTests.allTests),
      testCase(ExperimentalMutablePropertyTests.allTests),
      testCase(ComputedPropertyTests.allTests),
      testCase(MutableComputedPropertyTests.allTests),
      testCase(ExperimentalObservablePropertyTests.allTests),
      testCase(UniDirectionalPropertyBindingTests.allTests),
      testCase(BiDirectionalPropertyBindingTests.allTests),
      testCase(DependencyRecorderTests.allTests)
    ]
  }
#endif
