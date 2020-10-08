import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TreeTests.allTests),
        testCase(RenderObjectTreeRendererTests.allTests),
        testCase(RenderObjectTreeTests.allTests),
    ]
}
#endif
