import Foundation

class IsolationThread: Thread {
  let _main: () -> ()

  init(_ main: @escaping () -> ()) {
    self._main = main
  }

  override func main() {
    _main()
  }
}