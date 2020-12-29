import XCTest
@testable import ExperimentalReactiveProperties

final class BiDirectionalPropertyBindingTests: XCTestCase {
  func testPropertyChanged() {
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
    _ = property2.onChanged { _ in
      property2ChangedCallCount += 1
    }
    _ = property2.onHasValueChanged {
      property2HasValueCallCount += 1
    }

    property1.value = "test1"
    XCTAssertEqual(property2.value , "test1")
    XCTAssertEqual(property1HasValueCallCount, 1)
    XCTAssertEqual(property2HasValueCallCount, 1)
    XCTAssertEqual(property1ChangedCallCount, 0)
    XCTAssertEqual(property2ChangedCallCount, 0)

    /*property2.value = "test2"
    XCTAssertEqual(property1.value , "test2")
    XCTAssertEqual(property1HasValueCallCount, 1)
    XCTAssertEqual(property2HasValueCallCount, 1)
    XCTAssertEqual(property1ChangedCallCount, 1)
    XCTAssertEqual(property2ChangedCallCount, 1)

    property2.value = "test3"
    XCTAssertEqual(property1.value , "test3")
    XCTAssertEqual(property1HasValueCallCount, 1)
    XCTAssertEqual(property2HasValueCallCount, 1)
    XCTAssertEqual(property1ChangedCallCount, 2)
    XCTAssertEqual(property2ChangedCallCount, 2)*/
  }   
}