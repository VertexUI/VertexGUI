import XCTest
@testable import ReactiveProperties

final class StaticPropertyTests: XCTestCase {
  func testSimpleStaticProperty() {
    let property = StaticProperty("testString")
    XCTAssertEqual(property.value, "testString")
  }
  
  func testRecordAsDependency() { 
    let expectation = XCTestExpectation()
    let thread = IsolationThread {
      let recorder = DependencyRecorder.current
      recorder.recording = true
      let property = StaticProperty("test")
      _ = property.value
      recorder.recording = false

      XCTAssertEqual(recorder.recordedProperties.count, 1)
      XCTAssertEqual(recorder.recordedProperties.map(ObjectIdentifier.init), [ObjectIdentifier(property)])

      recorder.reset()
      expectation.fulfill()
    }
    thread.start()
    wait(for: [expectation], timeout: 1)
  }

  static let allTests = [
    ("testSimpleStaticProperty", testSimpleStaticProperty),
    ("testRecordAsDependecy", testRecordAsDependency)
  ]
}