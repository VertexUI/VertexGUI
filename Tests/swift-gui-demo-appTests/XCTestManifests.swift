import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(swift_gui_demo_appTests.allTests),
    ]
}
#endif
