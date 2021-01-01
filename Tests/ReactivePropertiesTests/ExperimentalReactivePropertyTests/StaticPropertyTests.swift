import XCTest
@testable import ExperimentalReactiveProperties

final class StaticPropertyTests: XCTestCase {
  func testSimpleStaticProperty() {
    let property = StaticProperty("testString")
    XCTAssertEqual(property.value, "testString")
  }
  
  func testRecordAsDependency() {
    let recorder = DependencyRecorder.current
    recorder.recording = true
    let property = StaticProperty("test")
    _ = property.value
    recorder.recording = false

    XCTAssertEqual(recorder.recordedProperties.count, 1)

    recorder.reset()
  }

  static let allTests = [
    ("testSimpleStaticProperty", testSimpleStaticProperty),
    ("testRecordAsDependecy", testRecordAsDependency)
  ]
}