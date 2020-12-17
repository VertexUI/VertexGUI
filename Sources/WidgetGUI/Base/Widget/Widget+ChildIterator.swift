public extension Widget {
  public struct ChildIterator: IteratorProtocol {
    private let count: Int
    private let getNext: (_ index: Int) -> Widget

    private var nextIndex = 0

    public init(count: Int, getNext: @escaping (_ index: Int) -> Widget) {
      self.count = count
      self.getNext = getNext
    }

    mutating public func next() -> Widget? {
      if nextIndex < count {
        defer { nextIndex += 1 }
        return getNext(nextIndex)
      } else {
        return nil
      }
    }
  }
}