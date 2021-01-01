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
    }, dependencies: [dependency])
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
    XCTAssertEqual(property.value, "test1")
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 1)

    property.value = "test2"
    XCTAssertEqual(property.value, "test2")
    XCTAssertEqual(dependency.value, "test2")
    XCTAssertEqual(onChangedCallCount, 1)
    XCTAssertEqual(onAnyChangedCallCount, 1)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
  }

  func testMultiPropertyBacked() {
    let dependency1 = MutableProperty<String>()
    let dependency2 = MutableProperty<String>()
    let property = MutableComputedProperty(compute: {
      dependency1.value + "," + dependency2.value
    }, apply: {
      let parts = $0.split(separator: ",")
      dependency1.value = String(parts[0])
      dependency2.value = String(parts[1])
    }, dependencies: [dependency1, dependency2])
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

    dependency1.value = "test1part1"
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 0)

    dependency2.value = "test1part2"
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 1)

    XCTAssertEqual(property.value, "test1part1,test1part2")

    dependency1.value = "test2part1"
    dependency2.value = "test2part2"
    XCTAssertEqual(property.value, "test2part1,test2part2")
    XCTAssertEqual(onChangedCallCount, 2)
    XCTAssertEqual(onAnyChangedCallCount, 2)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
  }

  func testNested() {
    let rootDependency = MutableProperty<String>()
    let level1Dependency = MutableComputedProperty(compute: {
      rootDependency.value
    }, apply: {
      rootDependency.value = $0
    }, dependencies: [rootDependency])
    let level2Dependency = MutableComputedProperty(compute: {
      level1Dependency.value
    }, apply: {
      level1Dependency.value = $0
    }, dependencies: [level1Dependency])
    let property = MutableComputedProperty(compute: {
      level2Dependency.value
    }, apply: {
      level2Dependency.value = $0
    }, dependencies: [level2Dependency])
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

    property.value = "test1"
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(rootDependency.value, "test1")
    XCTAssertEqual(level1Dependency.value, "test1")
    XCTAssertEqual(level2Dependency.value, "test1")

    rootDependency.value = "test2"
    XCTAssertEqual(onChangedCallCount, 1)
    XCTAssertEqual(onAnyChangedCallCount, 1)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(rootDependency.value, "test2")
    XCTAssertEqual(level1Dependency.value, "test2")
    XCTAssertEqual(level2Dependency.value, "test2")

    level1Dependency.value = "test3"
    XCTAssertEqual(onChangedCallCount, 2)
    XCTAssertEqual(onAnyChangedCallCount, 2)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(rootDependency.value, "test3")
    XCTAssertEqual(level1Dependency.value, "test3")
    XCTAssertEqual(level2Dependency.value, "test3")
  }

  func testDependencyDestruction() {
    var dependency1 = Optional(MutableProperty<String>())
    var dependency2 = Optional(MutableProperty<String>())
    var property = Optional(MutableComputedProperty(compute: {
      dependency1!.value + "," + dependency2!.value
    }, apply: {
      let parts = $0.split(separator: ",")
      dependency1!.value = String(parts[0])
      dependency2!.value = String(parts[1])
    }, dependencies: [dependency1!, dependency2!]))

    var dependency1Destroyed = false
    _ = dependency1!.onDestroyed {
      dependency1Destroyed = true
    }
    var dependency2Destroyed = false
    _ = dependency2!.onDestroyed {
      dependency2Destroyed = true
    }

    dependency1 = nil
    dependency2 = nil

    XCTAssertFalse(dependency1Destroyed)
    XCTAssertFalse(dependency2Destroyed)

    property = nil

    XCTAssertTrue(dependency1Destroyed)
    XCTAssertTrue(dependency2Destroyed)
  }

  func testUniDirectionalBindingSource() {

  }

  func testUniDirectionalBindingSink() {

  }

  func testBiDirectionalBindingWithOtherMutableComputedProperty() {

  }

  static var allTests = [
    ("testSingleVariableBacked", testSingleVariableBacked),
    ("testVariableAndPropertyBacked", testVariableAndPropertyBacked),
    ("testNotPrepopulatedPropertyBacked", testNotPrepopulatedPropertyBacked),
    ("testMultiPropertyBacked", testMultiPropertyBacked),
    ("testNested", testNested),
    ("testDependencyDestruction", testDependencyDestruction),
    ("testUniDirectionalBindingSource", testUniDirectionalBindingSource),
    ("testUniDirectionalBindingSink", testUniDirectionalBindingSink),
    ("testBiDirectionalBindingWithOtherMutableComputedProperty", testBiDirectionalBindingWithOtherMutableComputedProperty)
  ]
}