import XCTest
@testable import ExperimentalReactiveProperties

final class ComputedPropertyTests: XCTestCase {
  func testStaticCompute() {
    let property = ComputedProperty(compute: {
      "test"
    })
    XCTAssertEqual(property.value, "test")
  }

  func testOptionalStaticCompute() {
    let property = ComputedProperty(compute: {
      Optional("test")
    })
    XCTAssertEqual(property.value, "test")
    XCTAssertEqual(property.value, Optional("test"))
    XCTAssertTrue(property.value is String?)
  }

  func testVariableBackedNotifyDependenciesChanged() {
    var storage = "test1"
    let property = ComputedProperty(compute: {
      storage
    })
    XCTAssertEqual(property.value, "test1")

    storage = "test2"
    XCTAssertEqual(property.value, "test1")

    property.notifyDependenciesChanged()
    XCTAssertEqual(property.value, "test2")
  }

  func testMixedVariablePropertyDependeciesNotifyDependenciesChanged() {
    var variableDependency = "test1part1"
    let propertyDependency = MutableProperty<String>()
    let property = ComputedProperty(compute: {
      variableDependency + propertyDependency.value
    }, dependencies: [propertyDependency])
    var onHasValueChangedCallCount = 0
    var onAnyChangedCallCount = 0
    var onChangedCallCount = 0
    _ = property.onHasValueChanged {
      onHasValueChangedCallCount += 1
    }
    _ = property.onAnyChanged { _ in
      onAnyChangedCallCount += 1
    }
    _ = property.onChanged { _ in
      onChangedCallCount += 1
    }

    XCTAssertFalse(property.hasValue)

    variableDependency = "test2part1"
    property.notifyDependenciesChanged()
    XCTAssertFalse(property.hasValue)
    XCTAssertEqual(onHasValueChangedCallCount, 0)
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)

    propertyDependency.value = "test2part2"
    XCTAssertTrue(property.hasValue)
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(property.value, "test2part1test2part2")

    variableDependency = "test3part1"
    property.notifyDependenciesChanged()
    XCTAssertEqual(onHasValueChangedCallCount, 1)
    XCTAssertEqual(onChangedCallCount, 1)
    XCTAssertEqual(onAnyChangedCallCount, 1)
    XCTAssertEqual(property.value, "test3part1test2part2")
  }

  func testOnChangedAndOnAnyChangedCalled() {
    let dependencyProperty = MutableProperty<String>("test1")
    let computedProperty = ComputedProperty(compute: {
      dependencyProperty.value
    }, dependencies: [dependencyProperty])

    var onChangedCallCount = 0
    var onAnyChangedCallCount = 0

    _ = computedProperty.onChanged { _ in
      onChangedCallCount += 1
    }
    _ = computedProperty.onAnyChanged { _ in
      onAnyChangedCallCount += 1
    }

    dependencyProperty.value = "test2"

    XCTAssertEqual(onChangedCallCount, 1)
    XCTAssertEqual(onAnyChangedCallCount, 1)
  }

  func testManualDependencyChange() {
    let dependencyProperty = MutableProperty<String>("test1")
    let computedProperty = ComputedProperty(compute: {
      dependencyProperty.value     
    }, dependencies: [dependencyProperty])
    var handlerCallCount = 0
    let removeHandler = computedProperty.onChanged { _ in
      handlerCallCount += 1
    }
    dependencyProperty.value = "test2"
    XCTAssertEqual(computedProperty.value, "test2")
    XCTAssertEqual(handlerCallCount, 1)
    dependencyProperty.value = "test3"
    XCTAssertEqual(computedProperty.value, "test3")
    XCTAssertEqual(handlerCallCount, 2)
    removeHandler()
    dependencyProperty.value = "test4"
    XCTAssertEqual(computedProperty.value, "test4")
    XCTAssertEqual(handlerCallCount, 2)
  }

  func testManualNonPrepopulatedDependencyChange() {
    let dependencyProperty = MutableProperty<String>()
    let computedProperty = ComputedProperty<String>(compute: {
      dependencyProperty.value
    }, dependencies: [dependencyProperty])
    var handlerCallCount = 0
    _ = computedProperty.onChanged { _ in
      handlerCallCount += 1
    }
    dependencyProperty.value = "test1"
    XCTAssertEqual(handlerCallCount, 0)
    XCTAssertEqual(computedProperty.value, "test1")
    dependencyProperty.value = "test2"
    XCTAssertEqual(handlerCallCount, 1)
    XCTAssertEqual(computedProperty.value, "test2")
  }

  func testOptionalSelfManualOptionalDependencyChange() {
    let dependencyProperty = MutableProperty<String?>()
    let computedProperty = ComputedProperty<String?>(compute: {
      dependencyProperty.value
    }, dependencies: [dependencyProperty])
    var handlerCallCount = 0
    _ = computedProperty.onChanged { _ in
      handlerCallCount += 1
    }
    dependencyProperty.value = nil
    XCTAssertEqual(handlerCallCount, 0)
    XCTAssertNil(computedProperty.value)
    dependencyProperty.value = "test1"
    XCTAssertEqual(handlerCallCount, 1)
    XCTAssertEqual(computedProperty.value, "test1")
  }

  func testMultiManualDependencyChange() {
    let dependency1 = MutableProperty<String>()
    let dependency2 = MutableProperty<String>()
    let dependency3 = MutableProperty<String?>()
    let computedProperty = ComputedProperty<String>(compute: {
      dependency1.value + dependency2.value + (dependency3.value ?? "")
    }, dependencies: [dependency1, dependency2, dependency3])
    dependency1.value = "part0"
    dependency1.value = "part1"
    dependency2.value = "part2"
    dependency3.value = nil
    XCTAssertEqual(computedProperty.value, "part1part2")
    dependency3.value = "part3"
    XCTAssertEqual(computedProperty.value, "part1part2part3")
  }
  
  func testSingleDependencyHasValueChanged() {
    let dependencyProperty = MutableProperty<String>()
    let computedProperty = ComputedProperty(compute: {
      dependencyProperty.value
    }, dependencies: [dependencyProperty])
    var handlerCallCount = 0
    _ = computedProperty.onHasValueChanged {
      handlerCallCount += 1
    }
    dependencyProperty.value = "test1"
    XCTAssertEqual(handlerCallCount, 1)
    dependencyProperty.value = "test2"
    XCTAssertEqual(handlerCallCount, 1)
  }

  func testSingleDependencyOptionalValueHasValueChanged() {
    let dependencyProperty = MutableProperty<String?>()
    let computedProperty = ComputedProperty(compute: {
      dependencyProperty.value
    }, dependencies: [dependencyProperty])
    var handlerCallCount = 0
    _ = computedProperty.onHasValueChanged {
      handlerCallCount += 1
    }
    dependencyProperty.value = nil
    XCTAssertEqual(handlerCallCount, 1)
    dependencyProperty.value = "test1"
    XCTAssertEqual(handlerCallCount, 1)
  }

  func testMultiDependencyHasValueChanged() {
    let dependency1 = MutableProperty<String>()
    let dependency2 = MutableProperty<String?>()
    let dependency3 = MutableProperty<String>()
    let computedProperty = ComputedProperty(compute: {
      dependency1.value + (dependency2.value ?? "") + dependency3.value
    }, dependencies: [dependency1, dependency2, dependency3]) 
    var handlerCallCount = 0
    _ = computedProperty.onHasValueChanged {
      handlerCallCount += 1
    }
    dependency1.value = "test1"
    XCTAssertEqual(handlerCallCount, 0)
    dependency2.value = nil
    XCTAssertEqual(handlerCallCount, 0)
    dependency3.value = "test2"
    XCTAssertEqual(handlerCallCount, 1)
  }

  func testComputedPropertyDependencyOnChangedHasValueChanged() {
    let rootDep1 = MutableProperty<String>()
    let dep1 = ComputedProperty<String>(compute: {
      rootDep1.value
    }, dependencies: [rootDep1])
    let rootDep2 = MutableProperty<String?>()
    let dep2 = ComputedProperty<String?>(compute: {
      rootDep2.value
    }, dependencies: [rootDep2])
    let finalComputed = ComputedProperty(compute: {
      dep1.value + (dep2.value ?? "")
    }, dependencies: [dep1, dep2])
    var hasValueChangedCallCount = 0
    var onChangedCallCount = 0
    _ = finalComputed.onHasValueChanged {
      hasValueChangedCallCount += 1
    }
    let removeOnChanged = finalComputed.onChanged { _ in
      onChangedCallCount += 1
    }
    rootDep1.value = "test1"
    XCTAssertEqual(hasValueChangedCallCount, 0)
    XCTAssertEqual(onChangedCallCount, 0)
    rootDep2.value = nil
    XCTAssertEqual(hasValueChangedCallCount, 1)
    XCTAssertEqual(finalComputed.value, "test1")
    XCTAssertEqual(onChangedCallCount, 0)
    rootDep2.value = "test2"
    XCTAssertEqual(hasValueChangedCallCount, 1)
    XCTAssertEqual(finalComputed.value, "test1test2")
    XCTAssertEqual(onChangedCallCount, 1)
    rootDep2.value = nil
    XCTAssertEqual(hasValueChangedCallCount, 1)
    XCTAssertEqual(finalComputed.value, "test1")
    XCTAssertEqual(onChangedCallCount, 2)
    removeOnChanged()
    rootDep1.value = "test3"
    XCTAssertEqual(finalComputed.value, "test3")
    XCTAssertEqual(onChangedCallCount, 2)
  }

  func testDestroy() {
    let dependency = MutableProperty<String>()
    let property = ComputedProperty(compute: {
      dependency.value
    }, dependencies: [dependency])
    var onChangedCallCount = 0
    var onAnyChangedCallCount = 0
    var onHasValueChangedCallCount = 0
    var onDestroyedCallCount = 0
    _ = property.onChanged { _ in
      onChangedCallCount += 1
    }
    _ = property.onAnyChanged { _ in
      onAnyChangedCallCount += 1
    }
    _ = property.onHasValueChanged {
      onHasValueChangedCallCount += 1
    }
    _ = property.onDestroyed {
      onDestroyedCallCount += 1
    }

    property.destroy()
    dependency.value = "test"

    XCTAssertEqual(onChangedCallCount, 0)
    XCTAssertEqual(onAnyChangedCallCount, 0)
    XCTAssertEqual(onHasValueChangedCallCount, 0)
    XCTAssertEqual(onDestroyedCallCount, 1)
  }

  func testOnDestroyedCalledOnDeinit() {
    let dependency = MutableProperty<String>()
    var property = Optional(ComputedProperty(compute: {
      dependency.value
    }, dependencies: [dependency]))
    var onDestroyedCallCount = 0
    _ = property!.onDestroyed {
      onDestroyedCallCount += 1
    }

    property = nil

    XCTAssertEqual(onDestroyedCallCount, 1)
  }

  func testDependenciesNotDestroyedEarly() {
    var dependency = Optional(MutableProperty<String>("test"))
    var property = Optional(ComputedProperty(compute: {
      dependency!.value
    }, dependencies: [dependency!]))
    var dependencyOnDestroyedCallCount = 0
    _ = dependency!.onDestroyed {
      dependencyOnDestroyedCallCount += 1
    }

    dependency = nil
    XCTAssertEqual(dependencyOnDestroyedCallCount, 0)
    property = nil
    XCTAssertEqual(dependencyOnDestroyedCallCount, 1)
  }

  func testRecordAsDependency() {
    let expectation = XCTestExpectation()
    let thread = IsolationThread {
      let recorder = DependencyRecorder.current
      recorder.recording = true
      let property = ComputedProperty(compute: {
        "test"
      }, dependencies: [])
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

  func testAutomaticDependencyRecording() {
    let dependency1 = MutableProperty("test1part1")
    let dependency2 = MutableProperty("test1part2")
    let property = ComputedProperty(compute: {
      dependency1.value + dependency2.value
    })
    var onChangedCallCount = 0
    var onAnyChangedCallCount = 0
    _ = property.onChanged { _ in
      onChangedCallCount += 1
    }
    _ = property.onAnyChanged { _ in
      onAnyChangedCallCount += 1
    }

    XCTAssertTrue(property.hasValue)
    XCTAssertEqual(property.value, "test1part1test1part2")

    dependency1.value = "test2part1"
    XCTAssertEqual(onChangedCallCount, 1)
    XCTAssertEqual(onAnyChangedCallCount, 1)
    XCTAssertEqual(property.value, "test2part1test1part2")

    dependency2.value = "test2part2"
    XCTAssertEqual(onChangedCallCount, 2)
    XCTAssertEqual(onAnyChangedCallCount, 2)
    XCTAssertEqual(property.value, "test2part1test2part2")
  }

  static var allTests = [
    ("testStaticCompute", testStaticCompute),
    ("testOptionalStaticCompute", testOptionalStaticCompute),
    ("testVariableBackedNotifyDependenciesChanged", testVariableBackedNotifyDependenciesChanged),
    ("testMixedVariablePropertyDependeciesNotifyDependenciesChanged", testMixedVariablePropertyDependeciesNotifyDependenciesChanged),
    ("testOnChangedAndOnAnyChangedCalled", testOnChangedAndOnAnyChangedCalled),
    ("testManualDependencyChange", testManualDependencyChange),
    ("testManualNonPrepopulatedDependencyChange", testManualNonPrepopulatedDependencyChange),
    ("testOptionalSelfManualOptionalDependencyChange", testOptionalSelfManualOptionalDependencyChange),
    ("testMultiManualDependencyChange", testMultiManualDependencyChange),
    ("testSingleDependencyHasValueChanged", testSingleDependencyHasValueChanged),
    ("testSingleDependencyOptionalValueHasValueChanged", testSingleDependencyOptionalValueHasValueChanged),
    ("testComputedPropertyDependencyOnChangedHasValueChanged", testComputedPropertyDependencyOnChangedHasValueChanged),
    ("testDestroy", testDestroy),
    ("testOnDestroyedCalledOnDeinit", testOnDestroyedCalledOnDeinit),
    ("testDependenciesNotDestroyedEarly", testDependenciesNotDestroyedEarly),
    ("testRecordAsDependency", testRecordAsDependency),
    ("testAutomaticDependencyRecording", testAutomaticDependencyRecording)
  ]
}