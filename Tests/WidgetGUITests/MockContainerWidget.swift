import SwiftGUI

public class MockContainerWidget: Widget, SimpleStylableWidget {
  private let childrenBuilder: () -> ChildrenBuilder.Result
  
  public static let defaultStyleProperties = StyleProperties {
    $0.property1 = 0
  }
  lazy public private(set) var filledStyleProperties = getFilledStyleProperties()
  public var directStyleProperties = [AnyStyleProperties]()

  public init(@ChildrenBuilder children childrenBuilder: @escaping () -> ChildrenBuilder.Result) {
    self.childrenBuilder = childrenBuilder
  }

  override public func performBuild() {
    let result = childrenBuilder()
    children = result.children
    providedStyles.append(contentsOf: result.styles)
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