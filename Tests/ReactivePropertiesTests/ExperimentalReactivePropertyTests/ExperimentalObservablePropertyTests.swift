import XCTest
@testable import ExperimentalReactiveProperties

class ExperimentalObservablePropertyTests: XCTestCase {
  func testSettingDirectly() {
    let property = ObservableProperty<Double>()
    var onHasValueChangedCallCount = 0
    var onValueChangedCallCount = 0
    _ = property.onHasValueChanged {
      onHasValueChangedCallCount += 1
    }
    _ = property.onChanged { _ in
      onValueChangedCallCount += 1
    }

    XCTAssertFalse(property.hasValue)

    property.value = 1
    XCTAssertTrue(property.hasValue)
    XCTAssertEqual(property.value, 1)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(onValueChangedCallCount, 0)

    property.value = 2
    XCTAssertTrue(property.hasValue)
    XCTAssertEqual(property.value, 2)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(onValueChangedCallCount, 1)
  }

  func testUniDirectionalBindingSink() {
    let backingProperty = MutableProperty<Double>()
    let observableProperty = ObservableProperty<Double>()
    let binding = observableProperty.bind(backingProperty)
    var onHasValueChangedCallCount = 0
    var onValueChangedCallCount = 0
    _ = observableProperty.onHasValueChanged {
      onHasValueChangedCallCount += 1
    }
    _ = observableProperty.onChanged { _ in
      onValueChangedCallCount += 1
    }

    XCTAssertFalse(observableProperty.hasValue)

    backingProperty.value = 1
    XCTAssertTrue(observableProperty.hasValue)
    XCTAssertEqual(observableProperty.value, 1)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(onValueChangedCallCount, 0)

    backingProperty.value = 2
    XCTAssertTrue(observableProperty.hasValue)
    XCTAssertEqual(observableProperty.value, 2)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(onValueChangedCallCount, 1)
  }

  static var allTests = [
    ("testSettingDirectly", testSettingDirectly),
    ("testUniDirectionalBindingSink", testUniDirectionalBindingSink)
  ]
}