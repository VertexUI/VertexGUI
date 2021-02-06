import GfxMath

public struct BoxConfig: Equatable {
  public var preferredSize: DSize2
  public var minSize: DSize2
  public var maxSize: DSize2

  public init(
    preferredSize: DSize2,
    minSize: DSize2 = .zero,
    maxSize: DSize2 = .infinity
  ) {
    self.preferredSize = preferredSize
    self.minSize = minSize
    self.maxSize = maxSize
  }

  public init(size: DSize2) {
    self.preferredSize = size
    self.minSize = size
    self.maxSize = size
  }

  /** Adds given size to all sizes in BoxConfig. */
  public static func += (lhs: inout BoxConfig, rhs: DSize2) {
    lhs.minSize += rhs
    lhs.maxSize += rhs
    lhs.preferredSize += rhs
  }

  /** - See: BoxConfig.+= */
  public static func + (lhs: BoxConfig, rhs: DSize2) -> BoxConfig {
    var result = lhs
    result += rhs
    return result
  }
}

/*
/*
- Returns: a BoxConfig with the max value of the given BoxConfigs in each dimension
*/
public func max(_ configs: BoxConfig...) -> BoxConfig {
  var result = BoxConfig(size: .zero)
}*/