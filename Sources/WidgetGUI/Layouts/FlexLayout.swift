import GfxMath

public class FlexLayout: Layout {
  override public var parentPropertySupportDefinitions: StylePropertySupportDefinitions {
    StylePropertySupportDefinitions {
      (ParentKeys.direction, type: .specific(Direction.self), default: Direction.row)
    }
  }

  override public var childPropertySupportDefinitions: StylePropertySupportDefinitions {
    StylePropertySupportDefinitions {
      (ChildKeys.grow, type: .specific(Double.self))
      (ChildKeys.alignSelf, type: .specific(FlexAlign.self))
    }
  }

  @LayoutProperty(key: ParentKeys.direction)
  var direction: Direction

  override public func getBoxConfig() -> BoxConfig {
    widgets[0].boxConfig
  }

  override public func layout(constraints: BoxConstraints) -> DSize2 {
    let primaryAxisIndex: Int
    let secondaryAxisIndex: Int
    switch direction {
    case .row:
      primaryAxisIndex = 0
      secondaryAxisIndex = 1
    case .column:
      primaryAxisIndex = 1
      secondaryAxisIndex = 0
    }

    var maxSize = DSize2.zero
    for widget in widgets {
      var widgetConstraints = constraints
      if widget.stylePropertyValue(ChildKeys.alignSelf, as: FlexAlign.self) == .stretch {
        widgetConstraints.minSize.width = maxSize.width
      }
      widget.layout(constraints: widgetConstraints)

      var widgetPosition = DVec2.zero
      widgetPosition[primaryAxisIndex] = maxSize[primaryAxisIndex]
      widgetPosition[secondaryAxisIndex] = 0
      widget.position = widgetPosition

      maxSize[primaryAxisIndex] += widget.size[primaryAxisIndex]
      if widget.size[secondaryAxisIndex] > maxSize[secondaryAxisIndex] {
        maxSize[secondaryAxisIndex] = widget.size[secondaryAxisIndex]
      }
    }
    return maxSize
  }

  public enum Direction {
    case row, column
  }

  public enum FlexAlign {
    case start, stretch
  }

  public enum ParentKeys: String, StyleKey {
    case direction
  }

  public enum ChildKeys: String, StyleKey {
    case grow 
    case alignSelf 
  }
}