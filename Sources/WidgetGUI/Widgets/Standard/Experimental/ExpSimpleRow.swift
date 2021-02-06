import GfxMath

extension Experimental {
  public class SimpleRow: Widget {
    public init(classes: [String]? = nil, @MultiChildContentBuilder content contentBuilder: () -> MultiChildContentBuilder.Result) {
      super.init()
      if let classes = classes {
        self.classes.append(contentsOf: classes)
      }
      let content = contentBuilder()
      let children = content.childrenBuilder()
      self.children = children
      self.experimentalProvidedStyles.append(contentsOf: content.experimentalStyles)
    }

    override public func getContentBoxConfig() -> BoxConfig {
      var result = BoxConfig(preferredSize: .zero)
      for child in children {
        if child.boxConfig.preferredSize.width > result.preferredSize.width {
          result.preferredSize.width = child.boxConfig.preferredSize.width
        }
        result.preferredSize.height += child.boxConfig.preferredSize.height

        if child.boxConfig.minSize.width > result.minSize.width {
          result.minSize.width = child.boxConfig.minSize.width
        }
        result.minSize.height += child.boxConfig.minSize.height

        if child.boxConfig.maxSize.width > result.maxSize.width {
          result.maxSize.width = child.boxConfig.maxSize.width
        }
        result.maxSize.height += child.boxConfig.maxSize.height
      }
      return result
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      var currentPosition = DPoint2.zero
      var maxHeight = 0.0

      for child in children {
        child.position = currentPosition
        
        let childConstraints = BoxConstraints(minSize: .zero, maxSize: constraints.maxSize)
        child.layout(constraints: childConstraints)

        currentPosition.x += child.width
        if child.height > maxHeight {
          maxHeight = child.height
        }
      }

      return constraints.constrain(DSize2(currentPosition.x, maxHeight))
    }
  }
}