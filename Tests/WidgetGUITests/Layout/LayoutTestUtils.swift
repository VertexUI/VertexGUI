import SwiftGUI
import GfxMath

class LayoutTestUtils {
  typealias Root = MockRoot

  class ExplicitSizeWidget: Widget {
    var explicitPreferredSize: DSize2?
    var explicitMinSize: DSize2?
    var explicitMaxSize: DSize2?

    init(size: DSize2? = nil, preferredSize: DSize2? = nil, minSize: DSize2? = nil, maxSize: DSize2? = nil) {
      self.explicitPreferredSize = preferredSize 
      self.explicitMinSize = size ?? minSize
      self.explicitMaxSize = size ?? maxSize
      super.init()
    }

    override func performLayout(constraints: BoxConstraints) -> DSize2 {
      BoxConstraints(minSize: boxConfig.minSize, maxSize: boxConfig.maxSize).constrain(constraints.constrain(boxConfig.preferredSize))
    }
  }
}