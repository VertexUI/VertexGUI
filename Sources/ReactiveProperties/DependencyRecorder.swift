import Foundation
import Dispatch

internal class DependencyRecorder {
  var recording: Bool = false

  internal private(set) var recordedProperties = [AnyReactiveProperty]()

  internal init() {}

  func recordAccess(_ property: AnyReactiveProperty) {
    if !recording {
      fatalError("tried to record property access, but recorder is not in recording state")
    }
    recordedProperties.append(property)
  }

  func reset() {
    recording = false
    recordedProperties = []
  }
}

extension DependencyRecorder {
  static var recordersByThread = [ObjectIdentifier: DependencyRecorder]()
  static var semaphore = DispatchSemaphore(value: 1)

  /** the recorder for the current thread */
  static var current: DependencyRecorder {
    // TODO: find solution for cleaning up unused recorders
    let threadId = ObjectIdentifier(Thread.current)
    semaphore.wait()
    if recordersByThread[threadId] == nil {
      recordersByThread[threadId] = DependencyRecorder()
    }
    defer { semaphore.signal() }
    return recordersByThread[threadId]!
  }
}