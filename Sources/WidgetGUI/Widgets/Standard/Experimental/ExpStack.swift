import GfxMath

extension Experimental {
  public class Stack: Widget {
    public init(@MultiChildContentBuilder content contentBuilder: () -> MultiChildContentBuilder.Result) {
      let content = contentBuilder()
      super.init()
      children = content.childrenBuilder()
      provideStyles(content.experimentalStyles)
    }

    override public func getBoxConfig() -> BoxConfig {
      var maxSize = DSize2.zero
      var minSize = DSize2.infinity
      var maxPreferredSize = DSize2.zero

      for child in children {
        if child.boxConfig.minSize.width > minSize.width {
          minSize.width = child.boxConfig.minSize.width
        }
        if child.boxConfig.minSize.height > minSize.height {
          minSize.height = child.boxConfig.minSize.height
        }
        if child.boxConfig.maxSize.width > maxSize.width {
          maxSize.width = child.boxConfig.maxSize.width
        }
        if child.boxConfig.maxSize.height > maxSize.height {
          maxSize.height = child.boxConfig.maxSize.height
        }
        if child.boxConfig.preferredSize.width > maxPreferredSize.width {
          maxPreferredSize.width = child.boxConfig.preferredSize.width
        }
        if child.boxConfig.preferredSize.height > maxPreferredSize.height {
          maxPreferredSize.height = child.boxConfig.preferredSize.height
        }
      }

      return BoxConfig(preferredSize: maxPreferredSize, minSize: minSize, maxSize: maxSize)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      var largestSize = DSize2.zero
      for child in children {
        child.layout(constraints: constraints)
        if child.size.width > largestSize.width {
          largestSize.width = child.size.width
        }
        if child.size.height > largestSize.height {
          largestSize.height = child.size.height
        }
      }
      return constraints.constrain(largestSize)
    }
  }
}