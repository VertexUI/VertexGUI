    import XCTest
    @testable import swift_gui_demo_app

    final class swift_gui_demo_appTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            XCTAssertEqual(swift_gui_demo_app().text, "Hello, World!")
        }

        static var allTests = [
            ("testExample", testExample),
        ]
    }
