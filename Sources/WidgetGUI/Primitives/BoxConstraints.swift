import GfxMath
import Foundation

public struct BoxConstraints: Equatable, CustomDebugStringConvertible {
  public var minSize: DSize2
  public var maxSize: DSize2

  public var debugDescription: String {
    "BoxConstraints { min: \(minWidth) x \(minHeight) | max: \(maxWidth) x \(maxHeight) }"
  }

  // TODO: maybe add overflow property to indicate whether overflowing is allowed instead of using infinity in maxSize?
  public init(minSize: DSize2, maxSize: DSize2) {
    self.minSize = max(.zero, minSize)
    self.maxSize = max(.zero, maxSize)
  }

  public init(size: DSize2) {
    self.init(minSize: size, maxSize: size)
  }

  // min size of 0, max size infinity
  public static var unconstrained: BoxConstraints {
    BoxConstraints(minSize: .zero, maxSize: .infinity)
  }

  public var minWidth: Double {
    get {
      return minSize.width
    }

    set {
      minSize.width = newValue
    }
  }

  public var minHeight: Double {
    get {
      return minSize.height
    }

    set {
      minSize.height = newValue
    }
  }

  public var maxWidth: Double {
    get {
      return maxSize.width
    }

    set {
      maxSize.width = newValue
    }
  }

  public var maxHeight: Double {
    get {
      return maxSize.height
    }

    set {
      maxSize.height = newValue
    }
  }

  public func constrain(_ size: DSize2) -> DSize2 {
    return DSize2(
      min(max(size.width, minSize.width), maxSize.width),
      min(max(size.height, minSize.height), maxSize.height))
  }

  /** Subtracts given size from all sizes in BoxConstraints. */
  public static func -= (lhs: inout BoxConstraints, rhs: DSize2) {
    lhs.minSize -= rhs
    lhs.minSize = max(.zero, lhs.minSize)
    lhs.maxSize -= rhs
  }

  /** See: BoxConstraints.-= */
  public static func - (lhs: BoxConstraints, rhs: DSize2) -> BoxConstraints {
    var result = lhs
    result -= rhs
    return result
  }
}
