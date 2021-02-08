public extension Widget {
  public struct ChildIterator: IteratorProtocol {
    private let getNext: (_ index: Int) -> Widget?

    private var nextIndex = 0

    public init(getNext: @escaping (_ index: Int) -> Widget?) {
      self.getNext = getNext
    }

    mutating public func next() -> Widget? {
      defer { nextIndex += 1 }
      return getNext(nextIndex)
    }
  }
}