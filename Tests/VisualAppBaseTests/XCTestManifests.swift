import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(TreeTests.allTests),
            testCase(RenderObjectTreeRendererTests.allTests),
            testCase(RenderObjectTreeTests.allTests),
        ]
    }
#endif
