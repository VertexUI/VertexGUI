import SwiftGUI

public class MockLeafWidget: Widget, SimpleStylableWidget {
  
  public static let defaultStyleProperties = StyleProperties {
    $0.property1 = 0
    $0.property2 = ""
    $0.property3 = 0
  }
  lazy public private(set) var filledStyleProperties = getFilledStyleProperties()
  public var directStyleProperties = [AnyStyleProperties]()

  public init() {
  }

  override public func getBoxConfig() -> BoxConfig {
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
  public struct StyleProperties: SwiftGUI.StyleProperties {
    @StyleProperty
    public var property1: Double?
    @StyleProperty
    public var property2: String?
    @StyleProperty
    public var property3: Double?

    public init() {}
  }

  public func acceptsStyleProperties(_ properties: AnyStyleProperties) -> Bool {
    properties as? StyleProperties != nil
  }
}