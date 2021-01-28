import XCTest
@testable import ExperimentalReactiveProperties

final class UniDirectionalPropertyBindingTests: XCTestCase {
  func testSimpleSourceChangeAppliedToSink() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()
    property1.bind(property2)
    property2.value = "test3"
    XCTAssertEqual(property1.value, "test3")
  }

  func testInitialSourceValueAppliedToSink() {
    let property1 = MutableProperty("test1")
    let property2 = MutableProperty("test2")
    property1.bind(property2)
    XCTAssertEqual(property1.value, "test2")
  }

  func testNotPrepopulatedMutableToMutableBinding() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()
    property1.bind(property2)
    property2.value = "test"
    XCTAssertEqual(property1.value, "test")
  }

  func testChain() {
    let property1 = MutableProperty<String?>()
    let property2 = MutableProperty<String?>()
    let property3 = MutableProperty<String?>()
    let binding1 = UniDirectionalPropertyBinding(source: property1, sink: property2)
    let binding2 = UniDirectionalPropertyBinding(source: property2, sink: property3)

    property1.value = "test1"
    XCTAssertEqual(property1.value, "test1")
    XCTAssertEqual(property2.value, "test1")
    XCTAssertEqual(property3.value, "test1")

    property2.value = "test2"
    XCTAssertEqual(property1.value, "test1")
    XCTAssertEqual(property2.value, "test2")
    XCTAssertEqual(property3.value, "test2")
  }

  func testRedudantBinding() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()

    let binding1 = property1.bind(property2)
    let binding2 = property1.bind(property2)

    property2.value = "test1"
    XCTAssertEqual(property1.value, "test1")

    property2.value = "test2"
    XCTAssertEqual(property1.value, "test2")
  }

  func testTwoWayBinding() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()

    let binding1 = property1.bind(property2)
    let binding2 = property2.bind(property1)

    property1.value = "test1"
    XCTAssertEqual(property1.value, "test1")
    XCTAssertEqual(property2.value, "test1")

    property2.value = "test2"
    XCTAssertEqual(property1.value, "test2")
    XCTAssertEqual(property2.value, "test2")
  }

  func testPropertyDestroyed() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()
    let binding = property2.bind(property1)
    property1.value = "test1"

    property1.destroy()
    XCTAssertEqual(property1.registeredBindings.count, 0)
    XCTAssertEqual(property2.registeredBindings.count, 0)

    property1.value = "test2"
    XCTAssertEqual(property2.value, "test1")

    XCTAssertTrue(binding.destroyed)
  }

  func testNotDestroyedEarly() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()

    var binding = Optional(UniDirectionalPropertyBinding(source: property1, sink: property2))
    binding = nil
    property1.value = "test"

    XCTAssertEqual(property2.value, "test")
    XCTAssertEqual(property1.registeredBindings.count, 0)
    XCTAssertEqual(property2.registeredBindings.count, 1)
  }

  func testSourcePropertyRetained() {
    let backingProperty = MutableProperty<String>()
    var sourceProperty = Optional(ComputedProperty<String>(compute: {
      backingProperty.value
    }, dependencies: [backingProperty]))
    var sinkProperty = Optional(MutableProperty<String>())
    var binding = Optional(sinkProperty!.bind(sourceProperty!))
    var bindingOnDestroyedCalled = false
    _ = binding?.onDestroyed {
      bindingOnDestroyedCalled = true
    }
    var sourceOnDestroyedCalled = false
    _ = sourceProperty?.onDestroyed {
      sourceOnDestroyedCalled = true
    }
    var sinkOnDestroyedCalled = false
    _ = sinkProperty?.onDestroyed {
      sinkOnDestroyedCalled = true
    }

    backingProperty.value = "test1"
    XCTAssertEqual(sinkProperty!.value, "test1")

    sourceProperty = nil
    XCTAssertFalse(sourceOnDestroyedCalled)

    backingProperty.value = "test2"
    XCTAssertEqual(sinkProperty!.value, "test2")

    binding = nil
    sinkProperty = nil
    XCTAssertTrue(sinkOnDestroyedCalled)
    XCTAssertTrue(bindingOnDestroyedCalled)
    XCTAssertTrue(sourceOnDestroyedCalled)
  }

  func testDestroyedAfterPropertiesDeinitialized() {
    var property1 = Optional(MutableProperty<String>())
    var property2 = Optional(MutableProperty<String>())

    var binding = Optional(property1!.bind(property2!))

    var bindingDestroyed = false

    _ = binding!.onDestroyed {
      bindingDestroyed = true
    }

    binding = nil

    XCTAssertFalse(bindingDestroyed)

    property2!.value = "test"
    XCTAssertEqual(property2!.value, "test")

    property1 = nil
    property2 = nil

    XCTAssertTrue(bindingDestroyed)
  }

  static let allTests = [
    ("testSimpleSourceChangeAppliedToSink", testSimpleSourceChangeAppliedToSink),
    ("testInitialSourceValueAppliedToSink", testInitialSourceValueAppliedToSink),
    ("testNotPrepopulatedMutableToMutableBinding", testNotPrepopulatedMutableToMutableBinding),
    ("testChain", testChain),
    ("testRedudantBinding", testRedudantBinding),
    ("testTwoWayBinding", testTwoWayBinding),
    ("testPropertyDestroyed", testPropertyDestroyed),
    ("testNotDestroyedEarly", testNotDestroyedEarly),
    ("testSourcePropertyRetained", testSourcePropertyRetained),
    ("testDestroyedAfterPropertiesDeinitialized", testDestroyedAfterPropertiesDeinitialized)
  ]
}