import GfxMath

public class SimpleLinearLayout: Layout {
  override public var parentPropertySupportDefinitions: StylePropertySupportDefinitions {
    StylePropertySupportDefinitions {
      (ParentKeys.direction, type: .specific(Direction.self), default: Direction.row)
      (ParentKeys.alignContent, type: .specific(Align.self), default: Align.start)
      (ParentKeys.justifyContent, type: .specific(Justify.self), default: Justify.start)
    }
  }

  override public var childPropertySupportDefinitions: StylePropertySupportDefinitions {
    StylePropertySupportDefinitions {
      (ChildKeys.grow, type: .specific(Double.self), default: 0.0)
      (ChildKeys.shrink, type: .specific(Double.self), default: 0.0)
      (ChildKeys.alignSelf, type: .specific(Align.self))
      (ChildKeys.margin, type: .specific(Insets.self))
    }
  }

  @LayoutProperty(key: ParentKeys.direction)
  var direction: Direction
  @LayoutProperty(key: ParentKeys.alignContent)
  var alignContent: Align
  @LayoutProperty(key: ParentKeys.justifyContent)
  var justifyContent: Justify

  var axisIndices: (primaryAxisIndex: Int, secondaryAxisIndex: Int) {
    switch direction {
    case .row:
      return (0, 1)
    case .column:
      return (1, 0)
    }
  }

  override public func getBoxConfig() -> BoxConfig {
    let (primaryAxisIndex, secondaryAxisIndex) = axisIndices

    var accumulatedConfig = BoxConfig(preferredSize: .zero, minSize: .zero, maxSize: .infinity)
    for widget in widgets {
      accumulatedConfig.preferredSize[primaryAxisIndex] +=
        widget.boxConfig.preferredSize[primaryAxisIndex]
      if widget.boxConfig.preferredSize[secondaryAxisIndex]
        > accumulatedConfig.preferredSize[secondaryAxisIndex]
      {
        accumulatedConfig.preferredSize[secondaryAxisIndex] =
          widget.boxConfig.preferredSize[secondaryAxisIndex]
      }
      accumulatedConfig.minSize[primaryAxisIndex] += widget.boxConfig.minSize[primaryAxisIndex]
      if widget.boxConfig.minSize[secondaryAxisIndex]
        > accumulatedConfig.minSize[secondaryAxisIndex]
      {
        accumulatedConfig.minSize[secondaryAxisIndex] = widget.boxConfig.minSize[secondaryAxisIndex]
      }
      /*accumulatedConfig.maxSize[primaryAxisIndex] += widget.boxConfig.maxSize[primaryAxisIndex]
      if widget.boxConfig.maxSize[secondaryAxisIndex] > accumulatedConfig.maxSize[secondaryAxisIndex] {
        accumulatedConfig.maxSize[secondaryAxisIndex] = widget.boxConfig.maxSize[secondaryAxisIndex]
      }*/
    }
    return accumulatedConfig
  }

  override public func layout(constraints: BoxConstraints) -> DSize2 {
    let (primaryAxisIndex, secondaryAxisIndex) = axisIndices

    var totalGrowWeight = 0.0
    var totalShrinkWeight = 0.0

    // first pass to get preferred sizes, total grow and shrink weights, determine max cross axis size
    var accumulatedSize = DSize2.zero
    for widget in widgets {
      totalGrowWeight += widget.stylePropertyValue(ChildKeys.grow, as: Double.self)!
      totalShrinkWeight += widget.stylePropertyValue(ChildKeys.shrink, as: Double.self)!

      var widgetConstraints = BoxConstraints(minSize: .zero, maxSize: .infinity)
      widgetConstraints.maxSize[secondaryAxisIndex] = constraints.maxSize[secondaryAxisIndex]
      widget.layout(constraints: widgetConstraints)

      var widgetPosition = DVec2.zero
      accumulatedSize[primaryAxisIndex] += getWidgetStartMargin(widget, primaryAxisIndex)
      widgetPosition[primaryAxisIndex] = accumulatedSize[primaryAxisIndex]
      widgetPosition[secondaryAxisIndex] = getWidgetStartMargin(widget, secondaryAxisIndex)
      widget.position = widgetPosition

      accumulatedSize[primaryAxisIndex] += widget.size[primaryAxisIndex]
      accumulatedSize[primaryAxisIndex] += getWidgetEndMargin(widget, primaryAxisIndex)

      let widgetSecondaryAxisSpan =
        widget.position[secondaryAxisIndex] + widget.size[secondaryAxisIndex]
        + getWidgetEndMargin(widget, secondaryAxisIndex)
      if widgetSecondaryAxisSpan > accumulatedSize[secondaryAxisIndex] {
        accumulatedSize[secondaryAxisIndex] = widgetSecondaryAxisSpan
      }
    }

    var constrainedAccumulatedSize = constraints.constrain(accumulatedSize)

    // resolve cross axis
    var currentPrimaryAxisPosition = 0.0
    for widget in widgets {
      currentPrimaryAxisPosition += getWidgetStartMargin(widget, primaryAxisIndex)
      widget.position[primaryAxisIndex] = currentPrimaryAxisPosition

      var needRelayout = false
      var widgetConstraints = BoxConstraints(minSize: .zero, maxSize: .infinity)
      widgetConstraints.maxSize[secondaryAxisIndex] = constraints.maxSize[secondaryAxisIndex]

      // TODO: implement property definitions forwarding to children!
      switch widget.stylePropertyValue(ChildKeys.alignSelf, as: Align.self) ?? alignContent {
      case .start:
        widget.position[secondaryAxisIndex] = getWidgetStartMargin(widget, secondaryAxisIndex)

      case .center:
        let centerArea =
          constrainedAccumulatedSize[secondaryAxisIndex]
          - getWidgetStartMargin(widget, secondaryAxisIndex)
          - getWidgetEndMargin(widget, secondaryAxisIndex)
        widget.position[secondaryAxisIndex] =
          centerArea / 2 - widget.size[secondaryAxisIndex] / 2
          + getWidgetStartMargin(widget, secondaryAxisIndex)

      case .end:
        widget.position[secondaryAxisIndex] =
          constrainedAccumulatedSize[secondaryAxisIndex] - widget.size[secondaryAxisIndex]
          - getWidgetEndMargin(widget, secondaryAxisIndex)

      case .stretch:
        needRelayout = true
        widgetConstraints.minSize[secondaryAxisIndex] =
          constrainedAccumulatedSize[secondaryAxisIndex]
        widgetConstraints.maxSize[primaryAxisIndex] = widget.size[primaryAxisIndex]
      }

      if needRelayout {
        widget.layout(constraints: widgetConstraints)
      }

      currentPrimaryAxisPosition += widget.size[primaryAxisIndex]
      currentPrimaryAxisPosition += getWidgetEndMargin(widget, primaryAxisIndex)
    }

    accumulatedSize[primaryAxisIndex] = currentPrimaryAxisPosition
    constrainedAccumulatedSize = constraints.constrain(accumulatedSize)
    var deltaAccumulatedSize = constrainedAccumulatedSize - accumulatedSize

    // resolve main axis
    currentPrimaryAxisPosition = 0
    for widget in widgets {
      currentPrimaryAxisPosition += getWidgetStartMargin(widget, primaryAxisIndex)
      widget.position[primaryAxisIndex] = currentPrimaryAxisPosition

      let growWeight = widget.stylePropertyValue(ChildKeys.grow, as: Double.self)!
      if deltaAccumulatedSize[primaryAxisIndex] > 0 && growWeight > 0 {
        let relativeGrowWeight = growWeight / totalGrowWeight
        let primaryAxisGrowSpace = deltaAccumulatedSize[primaryAxisIndex] * relativeGrowWeight
        var targetSize = DSize2.zero
        targetSize[primaryAxisIndex] = widget.size[primaryAxisIndex] + primaryAxisGrowSpace
        targetSize[secondaryAxisIndex] = widget.size[secondaryAxisIndex]
        let widgetConstraints = BoxConstraints(size: targetSize)
        widget.layout(constraints: widgetConstraints)
      }

      let shrinkWeight = widget.stylePropertyValue(ChildKeys.shrink, as: Double.self)!
      if deltaAccumulatedSize[primaryAxisIndex] < 0 && shrinkWeight > 0 {
        let relativeShrinkWeight = shrinkWeight / totalShrinkWeight
        let primaryAxisShrinkSpace = deltaAccumulatedSize[primaryAxisIndex] * relativeShrinkWeight
        var targetSize = DSize2.zero
        targetSize[primaryAxisIndex] = widget.size[primaryAxisIndex] + primaryAxisShrinkSpace
        targetSize[secondaryAxisIndex] = widget.size[secondaryAxisIndex]
        let widgetConstraints = BoxConstraints(size: targetSize)
        widget.layout(constraints: widgetConstraints)
      }

      currentPrimaryAxisPosition += widget.size[primaryAxisIndex]
      currentPrimaryAxisPosition += getWidgetEndMargin(widget, primaryAxisIndex)
    }

    accumulatedSize[primaryAxisIndex] = currentPrimaryAxisPosition
    constrainedAccumulatedSize = constraints.constrain(accumulatedSize)
    deltaAccumulatedSize = constrainedAccumulatedSize - accumulatedSize

    // apply justify content
    if deltaAccumulatedSize[primaryAxisIndex] > 0 {
      switch justifyContent {
      case .start:
        break
      case .center:
        let mainAxisStartEndSpace = deltaAccumulatedSize[primaryAxisIndex] / 2
        for widget in widgets {
          widget.position[primaryAxisIndex] += mainAxisStartEndSpace
        }
      case .end:
        for widget in widgets {
          widget.position[primaryAxisIndex] += deltaAccumulatedSize[primaryAxisIndex]
        }
      }
    }

    return accumulatedSize
  }

  func getWidgetStartMargin(_ widget: Widget, _ axis: Int) -> Double {
    if axis == 0 {
      return widget.stylePropertyValue(ChildKeys.margin, as: Insets.self)?.left ?? 0
    } else {
      return widget.stylePropertyValue(ChildKeys.margin, as: Insets.self)?.top ?? 0
    }
  }

  func getWidgetEndMargin(_ widget: Widget, _ axis: Int) -> Double {
    if axis == 0 {
      return widget.stylePropertyValue(ChildKeys.margin, as: Insets.self)?.right ?? 0
    } else {
      return widget.stylePropertyValue(ChildKeys.margin, as: Insets.self)?.bottom ?? 0
    }
  }

  public enum Direction {
    case row, column
  }

  public enum Align {
    case start, center, end, stretch
  }

  public enum Justify {
    case start, center, end
  }

  public enum ParentKeys: String, StyleKey {
    case direction
    case alignContent
    case justifyContent
  }

  public enum ChildKeys: String, StyleKey {
    case grow
    case shrink
    case alignSelf
    case margin
  }
}
