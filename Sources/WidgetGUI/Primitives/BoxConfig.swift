import CustomGraphicsMath

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
}
