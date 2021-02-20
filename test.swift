public struct Callable {
  public init() {

  }

  func callAsFunction(_ block: () -> ()) {
    block()
    print("CALL")
  }
}

Callable()() {
  print("IN BLOCk")
}