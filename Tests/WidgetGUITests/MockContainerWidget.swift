import SwiftGUI

public class MockContainerWidget: Widget {
  private let childrenBuilder: () -> ChildrenBuilder.Result
  
  public init(@ChildrenBuilder children childrenBuilder: @escaping () -> ChildrenBuilder.Result) {
    self.childrenBuilder = childrenBuilder
  }

  override public func performBuild() {
    let result = childrenBuilder()
    children = result.children
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    .zero
  }
}