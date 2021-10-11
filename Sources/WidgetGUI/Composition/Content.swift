import Foundation
import Events

public protocol ContentProtocol: AnyObject {
  associatedtype Partial

  var partials: [Partial] { get set }

  var onChanged: EventHandlerManager<Void> { get }
  var onDestroy: EventHandlerManager<Void> { get }

  init(partials: [Partial])
}

extension ContentProtocol {
  func updateReplacementRanges(ranges: [Int: Range<Int>], from startIndex: Int, deltaLength: Int) -> [Int: Range<Int>] {
    var result = ranges
    for (rangeIndex, range) in result {
      if rangeIndex == startIndex {
        result[rangeIndex] = range.lowerBound..<range.upperBound + deltaLength
      } else if rangeIndex > startIndex {
        result[rangeIndex] = range.lowerBound + deltaLength..<range.upperBound + deltaLength
      }
    }
    return result
  }
}

// need to subclass NSObject because otherwise crashes occur
// when this object is being type casted e.g. in a mirror over a class
public class Content: NSObject, EventfulObject {
  public let onChanged = EventHandlerManager<Void>()
  public let onDestroy = EventHandlerManager<Void>()
  public private(set) var destroyed = false

  public func destroy() {
    onDestroy.invokeHandlers()
    removeAllEventHandlers()
    destroyed = true
  }

  deinit {
    if !destroyed {
      destroy()
    }
  }
}