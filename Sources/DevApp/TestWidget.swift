import SwiftGUI

public class TestWidget: ComposedWidget {
  override public func performBuild() {
    rootChild = Container().with(classes: ["container"]).withContent {
      Space(.zero)
    }
  }

  override public var style: Style? {
    Style(".container") {
      ($0.width, 200.0)
      ($0.height, 200.0)
      ($0.background, Color.red)
    }
  }
}