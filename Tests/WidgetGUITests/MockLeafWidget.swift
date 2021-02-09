import SwiftGUI

public class MockLeafWidget: Widget, SimpleStylableWidget {
  
  public static let defaultStyleProperties = StyleProperties {
    $0.property1 = 0
    $0.property2 = ""
    $0.property3 = 0
    $0.property4 = 0
  }
  lazy public private(set) var filledStyleProperties = getFilledStyleProperties()
  public var directStyleProperties = [AnyStyleProperties]()

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

  override public func getContentBoxConfig() -> BoxConfig {
    BoxConfig(preferredSize: .zero)
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    .zero
  }

  override public func renderContent() -> RenderObject? {
    nil
  }
}

extension MockLeafWidget {
  public enum State: String {
    case state1, state2, state3
  }

  public enum Mode: String {
    case mode1, mode2, mode3
  }

  public struct StyleProperties: SwiftGUI.StyleProperties {
    @StyleProperty
    public var property1: Double?
    @StyleProperty
    public var property2: String?
    @StyleProperty
    public var property3: Double?
    @StyleProperty
    public var property4: Double?

    public init() {}
  }

  public func acceptsStyleProperties(_ properties: AnyStyleProperties) -> Bool {
    properties as? StyleProperties != nil
  }
}