import VertexGUI

public class MockLeafWidget: Widget {
  
  /*override public var pseudoClasses: [String] {
    [state.rawValue, mode.rawValue]
  }*/

  private var state: State {
    didSet {
      notifySelectorChanged()
    }
  }

  public var mode: Mode {
    didSet {
      notifySelectorChanged()
    }
  }

  public init(state: State = .state1, mode: Mode = .mode1) {
    self.state = state
    self.mode = mode
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    .zero
  }
}

extension MockLeafWidget {
  public enum State: String {
    case state1, state2, state3
  }

  public enum Mode: String {
    case mode1, mode2, mode3
  }
}