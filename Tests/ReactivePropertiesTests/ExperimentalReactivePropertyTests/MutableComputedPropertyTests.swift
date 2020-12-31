import XCTest
@testable import ExperimentalReactiveProperties

class MutableComputedPropertyTests: XCTestCase {
  func testSingleVariableBacked() {
    var storage = "test1"
    let property = MutableComputedProperty(compute: {
      storage
    }, apply: {
      storage = $0
    })

    var onChangedCallCount = 0
    var onAnyChangedCallCount = 0
    var onHasValueChangedCallCount = 0

    _ = property.onChanged { _ in
      onChangedCallCount += 1
    }
    _ = property.onAnyChanged { _ in
      onAnyChangedCallCount += 1
    }
    _ = property.onHasValueChanged { _ in
      onHasValueChangedCallCount += 1
    }

    XCTAssertTrue(property.hasValue)
    XCTAssertEqual(property.value, "test1")

    storage = "test2"
    XCTAssertEqual(property.value, "test1")
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 0)
    property.notifyDependenciesChanged()
    XCTAssertEqual(property.value, "test2")
    XCTAssertEqual(onChangedCallCount, 1)
    XCTAssertEqual(onAnyChangedCallCount, 1)
    XCTAssertEqual(onHasValueChangedCallCount, 0)

    property.value = "test3"
    XCTAssertEqual(storage, "test3")
    XCTAssertEqual(property.value, "test3")
    XCTAssertEqual(onChangedCallCount, 2)
    XCTAssertEqual(onAnyChangedCallCount, 2)
    XCTAssertEqual(onHasValueChangedCallCount, 0)
  }

  func testVariableAndPropertyBacked() {
    var variableDependency = "test1part1"   
    var propertyDependency = MutableProperty("test1part2")
    var property = MutableComputedProperty(compute: {
      variableDependency + "," + propertyDependency.value
    }, apply: {
      let parts = $0.split(separator: ",")
      variableDependency = String(parts[0])
      propertyDependency.value = String(parts[1])
    }, dependencies: [propertyDependency])

    var onChangedCallCount = 0
    var onAnyChangedCallCount = 0
    var onHasValueChangedCallCount = 0

    _ = property.onChanged { _ in
      onChangedCallCount += 1
    }
    _ = property.onAnyChanged { _ in
      onAnyChangedCallCount += 1
    }
    _ = property.onHasValueChanged { _ in
      onHasValueChangedCallCount += 1
    }

    XCTAssertTrue(property.hasValue)
    XCTAssertEqual(property.value, "test1part1,test1part2")
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 0)

    property.value = "test2part1,test2part2"
    XCTAssertEqual(onChangedCallCount, 1)
    XCTAssertEqual(onAnyChangedCallCount, 1)
    XCTAssertEqual(onHasValueChangedCallCount, 0)
    XCTAssertEqual(property.value, "test2part1,test2part2")
    XCTAssertEqual(variableDependency, "test2part1")
    XCTAssertEqual(propertyDependency.value, "test2part2")

    propertyDependency.value = "test3part2"
    XCTAssertEqual(property.value, "test2part1,test3part2")
    XCTAssertEqual(onChangedCallCount, 2)
    XCTAssertEqual(onAnyChangedCallCount, 2)
    XCTAssertEqual(onHasValueChangedCallCount, 0)

    variableDependency = "test3part1"
    XCTAssertEqual(property.value, "test2part1,test3part2")
    XCTAssertEqual(onChangedCallCount, 2)
    XCTAssertEqual(onAnyChangedCallCount, 2)
    XCTAssertEqual(onHasValueChangedCallCount, 0)
    property.notifyDependenciesChanged()
    XCTAssertEqual(property.value, "test3part1,test3part2")
    XCTAssertEqual(onChangedCallCount, 3)
    XCTAssertEqual(onAnyChangedCallCount, 3)
    XCTAssertEqual(onHasValueChangedCallCount, 0)
  }
  
  func testNotPrepopulatedPropertyBacked() {
    let dependency = MutableProperty<String>()
    let property = MutableComputedProperty(compute: {
      dependency.value
    }, apply: {
      dependency.value = $0
    })
    var onChangedCallCount = 0
    var onAnyChangedCallCount = 0
    var onHasValueChangedCallCount = 0
    _ = property.onChanged { _ in
      onChangedCallCount += 1
    }
    _ = property.onAnyChanged { _ in
      onAnyChangedCallCount += 1
    }
    _ = property.onHasValueChanged { _ in
      onHasValueChangedCallCount += 1
    }
    
    XCTAssertFalse(property.hasValue)
    
    dependency.value = "test1"
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
  }

  func testMultiPropertyBacked() {

  }

  func testNested() {

  }

  func testNotDestroyedEarlyWithVariableDependencies() {

  }

  func testNotDestroyedEarlyWithPropertyDependencies() {

  }

  static var allTests = [
    ("testSingleVariableBacked", testSingleVariableBacked),
    ("testVariableAndPropertyBacked", testVariableAndPropertyBacked),
    ("testNotPrepopulatedPropertyBacked", testNotPrepopulatedPropertyBacked),
    ("testMultiPropertyBacked", testMultiPropertyBacked),
    ("testNested", testNested)
  ]
}