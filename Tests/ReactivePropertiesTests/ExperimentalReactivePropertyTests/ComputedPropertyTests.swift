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

  func testManualDependencyChange() {
    let dependencyProperty = MutableProperty<String>("test1")
    let computedProperty = ComputedProperty(compute: {
      dependencyProperty.value     
    }, dependencies: [dependencyProperty])
    var handlerCallCount = 0
    _ = computedProperty.onChanged { _ in
      handlerCallCount += 1
    }
    XCTAssertEqual(computedProperty.value, "test1")
    dependencyProperty.value = "test2"
    XCTAssertEqual(computedProperty.value, "test2")
    XCTAssertEqual(handlerCallCount, 1)
    dependencyProperty.value = "test3"
    XCTAssertEqual(computedProperty.value, "test3")
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
    print("HERE1")
    dependencyProperty.value = nil
    XCTAssertEqual(handlerCallCount, 0)
    XCTAssertNil(computedProperty.value)
    print("HERE2")
    dependencyProperty.value = "test1"
    XCTAssertEqual(handlerCallCount, 1)
    XCTAssertEqual(computedProperty.value, "test1")
  }

  func testMultiManualDependencyChange() {
    
  }
  
  func testSingleDependencyHasValueChanged() {
    let dependencyProperty = MutableProperty<String>()
    //let computedProperty = Computed
  }

  func testSingleDependencyOptionalValueHasValueChanged() {

  }

  func testMultiDependencyHasValueChanged() {

  }

  static var allTests = [
    ("testStaticCompute", testStaticCompute),
    ("testOptionalStaticCompute", testOptionalStaticCompute),
    ("testManualDependencyChange", testManualDependencyChange),
    ("testManualNonPrepopulatedDependencyChange", testManualNonPrepopulatedDependencyChange),
    ("testOptionalSelfManualOptionalDependencyChange", testOptionalSelfManualOptionalDependencyChange)
  ]
}