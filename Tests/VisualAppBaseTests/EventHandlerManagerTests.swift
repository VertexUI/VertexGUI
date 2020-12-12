import Events
@testable import VisualAppBase
import XCTest

final class EventHandlerManagerTests: XCTestCase {
  func testHandlerOrder() {
    let manager = EventHandlerManager<Void>()
    let handlerCount = 5
    var previousCall = -1
    for i in 0..<handlerCount {
      manager.addHandler {
        XCTAssertEqual(previousCall, i - 1)
        previousCall = i
      }
    }
    manager.addHandler(at: 0) {
      XCTAssertEqual(previousCall, -1)
    }
    manager.invokeHandlers(())
  }
}
