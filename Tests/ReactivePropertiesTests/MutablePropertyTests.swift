import XCTest
import ReactiveProperties

final class MutablePropertyTests: XCTestCase {
  func testMutableProperty() {
    var mutable = MutableProperty("InitialValue")

    var changeCount = 0
    let removeOnChangedHandler = mutable.onChanged { _ in
      changeCount += 1
    }

    mutable.value = "InitialValue" // this should not increase the change count
    XCTAssertEqual(changeCount, 0)
    
    mutable.value = "Value1"
    mutable.value = "Value2"
    XCTAssertEqual(changeCount, 2)
    
    removeOnChangedHandler() // now the change count shouldn't increase anymore
    mutable.value = "Value3"

    XCTAssertEqual(mutable.value, "Value3")
    XCTAssertEqual(changeCount, 2)
  }

  func testMutablePropertyBinding() {
    var mutable = MutableProperty("InitialValue")
    var binding = mutable.binding

    var mutableChangeCount = 0
    var bindingChangeCount = 0

    let removeOnMutableChangedHandler = mutable.onChanged { _ in
      mutableChangeCount += 1
    }
    let removeOnBindingChangedHandler = binding.onChanged { _ in
      bindingChangeCount += 1
    }

    mutable.value = "InitialValue"
    XCTAssertEqual(mutableChangeCount, 0)
    XCTAssertEqual(bindingChangeCount, 0)

    mutable.value = "Value1"
    XCTAssertEqual(mutable.value, binding.value)
    XCTAssertEqual(mutableChangeCount, 1)
    XCTAssertEqual(bindingChangeCount, 1)

    binding.value = "Value2"
    XCTAssertEqual(mutable.value, binding.value)
    XCTAssertEqual(mutableChangeCount, 2)
    XCTAssertEqual(bindingChangeCount, 2)

    removeOnBindingChangedHandler()
    mutable.value = "Value3"
    XCTAssertEqual(mutable.value, binding.value)
    XCTAssertEqual(mutableChangeCount, 3)
    XCTAssertEqual(bindingChangeCount, 2)

    removeOnMutableChangedHandler()
    binding.value = "Value4"
    XCTAssertEqual(mutable.value, binding.value)
    XCTAssertEqual(mutableChangeCount, 3)
    XCTAssertEqual(bindingChangeCount, 2)
  }

  func testMutablePropertyObservable() {
    let mutable = MutableProperty("InitialValue")
    let observable = mutable.observable

    var changeCount = 0
    let removeOnChangedHandler = observable.onChanged { _ in
      changeCount += 1
    }
    
    mutable.value = "InitialValue"
    XCTAssertEqual(changeCount, 0)

    mutable.value = "Value1"
    XCTAssertEqual(observable.value, mutable.value)
    XCTAssertEqual(changeCount, 1)

    removeOnChangedHandler()
    mutable.value = "Value2"
    XCTAssertEqual(observable.value, mutable.value)
    XCTAssertEqual(changeCount, 1)
  }

  func testMutablePropertyComputedObservable() {
    let mutable = MutableProperty("InitialValue")
    var computed: ComputedProperty<String>? = mutable.compute { $0.lowercased() }
    let observable = computed!.observable
    computed = nil

    var changeCount = 0
    let removeObservableOnChangedHandler = observable.onChanged { _ in
      changeCount += 1
    }

    mutable.value = "InitialValue"
    XCTAssertEqual(observable.value, "initialvalue")
    XCTAssertEqual(changeCount, 0)

    mutable.value = "Initialvalue" // note the V is now a v
    XCTAssertEqual(observable.value, "initialvalue")
    XCTAssertEqual(changeCount, 0)

    mutable.value = "Value1"
    XCTAssertEqual(observable.value, "value1")
    XCTAssertEqual(changeCount, 1)

    removeObservableOnChangedHandler()
    mutable.value = "Value2"
    XCTAssertEqual(observable.value, "value2")
    XCTAssertEqual(changeCount, 1)
  }

  func testComputed() {
    var mutable = MutableProperty("Wow")
    var changeCount = 0
    var computed = mutable.compute { Optional<Int>($0.count) }
    _ = computed.onChanged { _ in
      changeCount += 1
    }
    mutable.value = "New Value"
    mutable.value = "New Volau"
    XCTAssertEqual(changeCount, 1)
  }
  
  static var allTests = [
    ("testMutableProperty", testMutableProperty),
    ("testMutablePropertyBinding", testMutablePropertyBinding),
    ("testMutablePropertyObservable", testMutablePropertyObservable),
    ("testMutablePropertyComputedObservable", testMutablePropertyComputedObservable),
    ("testComputed", testComputed)
  ]
}
