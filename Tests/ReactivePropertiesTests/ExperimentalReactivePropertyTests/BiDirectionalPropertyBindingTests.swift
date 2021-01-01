import XCTest
@testable import ExperimentalReactiveProperties

final class BiDirectionalPropertyBindingTests: XCTestCase {
  func testEventHandlers() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()
    let binding = BiDirectionalPropertyBinding(property1, property2)
    var property1HasValueCallCount = 0
    var property1ChangedCallCount = 0
    var property2HasValueCallCount = 0
    var property2ChangedCallCount = 0
    _ = property1.onChanged { _ in
      property1ChangedCallCount += 1
    }
    _ = property1.onHasValueChanged {
      property1HasValueCallCount += 1
    }
    let removeProperty2OnChanged = property2.onChanged { _ in
      property2ChangedCallCount += 1
    }
    _ = property2.onHasValueChanged {
      property2HasValueCallCount += 1
    }

    property1.value = "test1"
    XCTAssertEqual(property1.value, "test1")
    XCTAssertEqual(property2.value, "test1")
    XCTAssertEqual(property1HasValueCallCount, 1)
    XCTAssertEqual(property2HasValueCallCount, 1)
    XCTAssertEqual(property1ChangedCallCount, 0)
    XCTAssertEqual(property2ChangedCallCount, 0)

    property1.value = "test2"
    XCTAssertEqual(property1.value, "test2")
    XCTAssertEqual(property2.value, "test2")
    XCTAssertEqual(property1HasValueCallCount, 1)
    XCTAssertEqual(property2HasValueCallCount, 1)
    XCTAssertEqual(property1ChangedCallCount, 1)
    XCTAssertEqual(property2ChangedCallCount, 1)

    property2.value = "test3"
    XCTAssertEqual(property1.value, "test3")
    XCTAssertEqual(property1HasValueCallCount, 1)
    XCTAssertEqual(property2HasValueCallCount, 1)
    XCTAssertEqual(property1ChangedCallCount, 2)
    XCTAssertEqual(property2ChangedCallCount, 2)

    removeProperty2OnChanged()
    property2.value = "test4"
    XCTAssertEqual(property1ChangedCallCount, 3)
    XCTAssertEqual(property2ChangedCallCount, 2)
  }

  func testChainedWithBiDirectionalBinding() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()
    let property3 = MutableProperty<String>()

    let binding1 = BiDirectionalPropertyBinding(property1, property2)
    let binding2 = BiDirectionalPropertyBinding(property2, property3)

    property1.value = "test1"
    XCTAssertEqual(property1.value, "test1")
    XCTAssertEqual(property1.value, "test1")

    property3.value = "test2"
    XCTAssertEqual(property1.value, "test2")
    XCTAssertEqual(property1.value, "test2")

    property2.value = "test3"
    XCTAssertEqual(property1.value, "test3")
    XCTAssertEqual(property3.value, "test3")
  }

  func testRedundantBindings() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()

    let binding1 = BiDirectionalPropertyBinding(property1, property2)
    let binding2 = BiDirectionalPropertyBinding(property1, property2)

    property1.value = "test1"
    XCTAssertEqual(property2.value, "test1")

    property2.value = "test2"
    XCTAssertEqual(property1.value, "test2")
    XCTAssertEqual(property2.value, "test2")
  }

  func testChainedWithUniDirectionalBinding() {
    let property1 = MutableProperty<String?>()
    let property2 = MutableProperty<String?>()
    let property3 = MutableProperty<String?>()

    let binding1 = UniDirectionalPropertyBinding(source: property1, sink: property2)
    let binding2 = BiDirectionalPropertyBinding(property2, property3)

    property1.value = nil
    XCTAssertEqual(property2.value, nil)
    XCTAssertEqual(property3.value, nil)

    property1.value = "test1"
    XCTAssertEqual(property2.value, "test1")
    XCTAssertEqual(property3.value, "test1")

    property2.value = "test2"
    XCTAssertEqual(property1.value, "test1")
    XCTAssertEqual(property3.value, "test2")

    property3.value = "test3"
    XCTAssertEqual(property2.value, "test3")
    XCTAssertEqual(property1.value, "test1")
  }

  func testPropertyDestroyed() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()

    let binding = BiDirectionalPropertyBinding(property1, property2)

    property1.value = "test1"
    property1.destroy()
    property1.value = "test2"

    XCTAssertEqual(property2.registeredBindings.count, 0)
    XCTAssertEqual(property1.value, "test2")
    XCTAssertEqual(property2.value, "test1")
  }

  func testDestroy() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()

    let binding = BiDirectionalPropertyBinding(property1, property2)

    property1.value = "test1"
    binding.destroy()
    property2.value = "test2"

    XCTAssertEqual(property1.registeredBindings.count, 0)
    XCTAssertEqual(property1.value, "test1")
    XCTAssertEqual(property2.value, "test2")
  }

  func testNotDestroyedEarly() {
    let property1 = MutableProperty<String>()
    let property2 = MutableProperty<String>()

    var binding = Optional(BiDirectionalPropertyBinding(property1, property2))
    binding = nil

    property1.value = "test"

    XCTAssertEqual(property1.registeredBindings.count, 1)
    XCTAssertEqual(property1.value, "test")
    XCTAssertEqual(property2.registeredBindings.count, 1)
    XCTAssertEqual(property2.value, "test")
  }

  func testDestroyedAfterPropertiesDeinitialized() {
    var property1 = Optional(MutableProperty<String>())
    var property2 = Optional(MutableProperty<String>())
    var binding = Optional(BiDirectionalPropertyBinding(property1!, property2!))

    var bindingDestroyed = false
    _ = binding!.onDestroyed {
      bindingDestroyed = true
    }

    binding = nil

    XCTAssertFalse(bindingDestroyed)

    property1 = nil
    property2 = nil

    XCTAssertTrue(bindingDestroyed)
  }

  static var allTests = [
    ("testEventHandlers", testEventHandlers),
    ("testChainedWithBiDirectionalBinding", testChainedWithBiDirectionalBinding),
    ("testRedundantBindings", testRedundantBindings),
    ("testChainedWithUniDirectionalBinding", testChainedWithUniDirectionalBinding),
    ("testPropertyDestroyed", testPropertyDestroyed),
    ("testDestroy", testDestroy),
    ("testNotDestroyedEarly", testNotDestroyedEarly),
    ("testDestroyedAfterPropertiesDeinitialized", testDestroyedAfterPropertiesDeinitialized)
  ]
}