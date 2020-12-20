import SwiftGUI

public class MockContainerWidget: Widget, SimpleStylableWidget {
  private let childrenBuilder: () -> [Widget]
  
  public static let defaultStyleProperties = StyleProperties {
    $0.property1 = 0
  }
  lazy public private(set) var filledStyleProperties = getFilledStyleProperties()
  public var directStyleProperties = [AnyStyleProperties]()

  public init(@WidgetBuilder children childrenBuilder: @escaping () -> [Widget]) {
    self.childrenBuilder = childrenBuilder
  }

  override public func performBuild() {
    children = childrenBuilder()
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

extension MockContainerWidget {
  public struct StyleProperties: SwiftGUI.StyleProperties {
    @StyleProperty
    public var property1: Double?

    public init() {}
  }

  public func acceptsStyleProperties(_ properties: AnyStyleProperties) -> Bool {
    properties is StyleProperties
  }
}