import XCTest
@testable import ExperimentalReactiveProperties

final class ExperimentalMutablePropertyTests: XCTestCase {
  func testInstantiation() {
    let property = MutableProperty("testString")
    XCTAssertEqual(property.value, "testString")
  }

  func testValueSet() {
    let property = MutableProperty("testString")
    property.value = "testString2"
    XCTAssertEqual(property.value, "testString2")
  }

  func testPrepopulatedOnChanged() {
    let property = MutableProperty("testString")
    var handlerCallCount = 0
    _ = property.onChanged {
      handlerCallCount += 1

      XCTAssertEqual($0.old, "testString")
      XCTAssertEqual($0.new, "testString2")
    }
    property.value = "testString2"
    XCTAssertEqual(handlerCallCount, 1)
  }

  func testNotPrepopulatedOnChanged() {
    let property = MutableProperty<String>()
    var handlerCallCount = 0
    _ = property.onChanged { _ in
      handlerCallCount += 1
    }
    property.value = "testString1"
    XCTAssertEqual(handlerCallCount, 0)
    property.value = "testString2"
    XCTAssertEqual(handlerCallCount, 1)
  }

  func testOnChangedHandlerRemove() {
    let property = MutableProperty("test")
    var handlerCallCount = 0
    let removeHandler = property.onChanged { _ in
      handlerCallCount += 1
    }
    property.value = "test1"
    removeHandler()
    property.value = "test2"
    XCTAssertEqual(handlerCallCount, 1)
  }

  func testOptionalOnChanged() {
    let property = MutableProperty<String?>()
    var onChangedCalled = false
    _ = property.onChanged {
      onChangedCalled = true
      XCTAssertEqual($0.old, nil)
      XCTAssertEqual($0.new, "test1")
    }
    property.value = "test1"
    XCTAssertTrue(onChangedCalled)
  }

  func testHasValueChanged() {
    let property = MutableProperty<String>()
    var handlerCallCount = 0
    _ = property.onHasValueChanged {
      handlerCallCount += 1
    }
    property.value = "test1"
    XCTAssertEqual(handlerCallCount, 1)
    property.value = "test2"
    XCTAssertEqual(handlerCallCount, 1)
  }

  func testOptionalValueHasValueChanged() {
    let property = MutableProperty<String?>()
    var handlerCallCount = 0
    _ = property.onHasValueChanged {
      handlerCallCount += 1
    }
    property.value = "test1"
    XCTAssertEqual(handlerCallCount, 1)
    property.value = "test2"
    XCTAssertEqual(handlerCallCount, 1)
  }

  static let allTests = [
    ("testInstantiation", testInstantiation),
    ("testValueSet", testValueSet),
    ("testPrepopulatedOnChanged", testPrepopulatedOnChanged),
    ("testNotPrepopulatedOnChanged", testNotPrepopulatedOnChanged),
    ("testOnChangedHandlerRemove", testOnChangedHandlerRemove),
    ("testOptionalOnChanged", testOptionalOnChanged),
    ("testHasValueChanged", testHasValueChanged),
    ("testOptionalValueHasValueChanged", testOptionalValueHasValueChanged)
  ]
}