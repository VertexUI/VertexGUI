import XCTest
@testable import ReactiveProperties

class ObservablePropertyTests: XCTestCase {
  func testSettingDirectly() {
    let property = ObservableProperty<Double>()
    var onHasValueChangedCallCount = 0
    var onValueChangedCallCount = 0
    var onAnyChangedCallCount = 0
    _ = property.onHasValueChanged {
      onHasValueChangedCallCount += 1
    }
    _ = property.onChanged { _ in
      onValueChangedCallCount += 1
    }
    _ = property.onAnyChanged { _ in
      onAnyChangedCallCount += 1
    }

    XCTAssertFalse(property.hasValue)

    property.value = 1
    XCTAssertTrue(property.hasValue)
    XCTAssertEqual(property.value, 1)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(onValueChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)

    property.value = 2
    XCTAssertTrue(property.hasValue)
    XCTAssertEqual(property.value, 2)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(onValueChangedCallCount, 1)
    XCTAssertEqual(onAnyChangedCallCount, 1)
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

  func testMultiLayer() {
    let storage = MutableProperty<Double>()
    let firstObservableProperty = ObservableProperty<Double>()
    firstObservableProperty.bind(storage)
    let computedProperty = ComputedProperty(compute: {
      firstObservableProperty.value
    }, dependencies: [firstObservableProperty])
    let secondObservableProperty = ObservableProperty<Double>()
    secondObservableProperty.bind(computedProperty)
    var onChangedCallCount = 0
    var onHasValueChangedCallCount = 0
    _ = secondObservableProperty.onHasValueChanged {
      onHasValueChangedCallCount += 1
    }
    _ = secondObservableProperty.onChanged { _ in
      onChangedCallCount += 1
    }
    
    XCTAssertFalse(secondObservableProperty.hasValue)

    storage.value = 1.0
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertTrue(secondObservableProperty.hasValue)
    XCTAssertEqual(secondObservableProperty.value, 1.0)

    storage.value = 2.0
    XCTAssertEqual(onChangedCallCount, 1)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertTrue(secondObservableProperty.hasValue)
    XCTAssertEqual(secondObservableProperty.value, 2.0)
  }

  static var allTests = [
    ("testSettingDirectly", testSettingDirectly),
    ("testUniDirectionalBindingSink", testUniDirectionalBindingSink),
    ("testMultiLayer", testMultiLayer)
  ]
}