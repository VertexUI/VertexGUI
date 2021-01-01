import XCTest
import Dispatch
import Foundation
@testable import ExperimentalReactiveProperties

class DependencyRecorderTests: XCTestCase {
  func testAsyncConcurrentDispatchQueueRecording() {
    let expectation = XCTestExpectation(description: "perform concurrent accesses")

    let queue = DispatchQueue(label: "test", attributes: [.concurrent])
    let semaphore = DispatchSemaphore(value: 1)
    let targetIterationCount = 10
    let targetPropertyAccessCount = 500
    var accessCount = 0
    var finishedIterationCount = 0
    
    func performAccesses() {
      DependencyRecorder.current.recording = true
      for _ in 0..<targetPropertyAccessCount {
        let property = MutableProperty<String>("")
        _ = property.value
      }
      let thisIterationAccessCount = DependencyRecorder.current.recordedProperties.count
      DependencyRecorder.current.reset()

      XCTAssertEqual(thisIterationAccessCount, targetPropertyAccessCount)

      semaphore.wait()
      accessCount += thisIterationAccessCount
      finishedIterationCount += 1
      if finishedIterationCount == targetIterationCount {
        expectation.fulfill()
      }
      semaphore.signal()
    }
    for _ in 0..<targetIterationCount {
      queue.async(execute: performAccesses)
    }
    
    wait(for: [expectation], timeout: 10.0)

    XCTAssertEqual(accessCount, targetIterationCount * targetPropertyAccessCount)
  }

  static var allTests = [
    ("testAsyncConcurrentDispatchQueueRecording", testAsyncConcurrentDispatchQueueRecording)
  ]
}