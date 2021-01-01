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
      XCTAssertEqual($0.old, "test1")
      XCTAssertEqual($0.new, nil)
    }
    property.value = "test1"
    XCTAssertFalse(onChangedCalled)
    property.value = nil
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
  
  func testDestroy() {
    var mutable = MutableProperty<String>()
    var onChangedCallCount = 0
    var onAnyChangedCallCount = 0
    var onHasValueChangedCallCount = 0
    var onDestroyedCallCount = 0
    _ = mutable.onChanged { _ in
      onChangedCallCount += 1
    }
    _ = mutable.onAnyChanged { _ in
      onAnyChangedCallCount += 1
    }
    _ = mutable.onHasValueChanged {
      onHasValueChangedCallCount += 1
    }
    _ = mutable.onDestroyed {
      onDestroyedCallCount += 1
    }
    mutable.destroy()
    mutable.value = "test"
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 0)
    XCTAssertEqual(onDestroyedCallCount, 1)
  }

  func testOnDestroyedCalledOnDeinit() {
    var mutable = Optional(MutableProperty<String>())
    var onDestroyedCallCount = 0
    _ = mutable!.onDestroyed {
      onDestroyedCallCount += 1
    }
    mutable = nil
    XCTAssertEqual(onDestroyedCallCount, 1)
  }
 
  func testRecordAsDependency() {
    let recorder = DependencyRecorder.current
    recorder.recording = true
    let property = MutableProperty("test")
    _ = property.value
    recorder.recording = false

    XCTAssertEqual(recorder.recordedProperties.count, 1)

    recorder.reset()
  }

  static let allTests = [
    ("testInstantiation", testInstantiation),
    ("testValueSet", testValueSet),
    ("testPrepopulatedOnChanged", testPrepopulatedOnChanged),
    ("testNotPrepopulatedOnChanged", testNotPrepopulatedOnChanged),
    ("testOnChangedHandlerRemove", testOnChangedHandlerRemove),
    ("testOptionalOnChanged", testOptionalOnChanged),
    ("testHasValueChanged", testHasValueChanged),
    ("testOptionalValueHasValueChanged", testOptionalValueHasValueChanged),
    ("testDestroy", testDestroy),
    ("testOnDestroyedCalledOnDeinit", testOnDestroyedCalledOnDeinit),
    ("testRecordAsDependency", testRecordAsDependency)
  ]
}