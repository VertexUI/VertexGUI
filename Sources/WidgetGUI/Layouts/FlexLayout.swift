import GfxMath

public class FlexLayout: Layout {
  //@LayoutProperty(\.$direction)
  var direction: Direction = .row

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
      /*if widget.stylePropertyValue(ChildKeys.alignSelf, as: FlexAlign.self) == .stretch {
        widgetConstraints.minSize.width = maxSize.width
      }*/
      widget.layout(constraints: widgetConstraints)

      var widgetPosition = DVec2.zero
      widgetPosition[primaryAxisIndex] = maxSize[primaryAxisIndex]
      widgetPosition[secondaryAxisIndex] = 0
      widget.layoutedPosition = widgetPosition

      maxSize[primaryAxisIndex] += widget.layoutedSize[primaryAxisIndex]
      if widget.layoutedSize[secondaryAxisIndex] > maxSize[secondaryAxisIndex] {
        maxSize[secondaryAxisIndex] = widget.layoutedSize[secondaryAxisIndex]
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
}