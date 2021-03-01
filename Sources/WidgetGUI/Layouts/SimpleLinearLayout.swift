import GfxMath

public class SimpleLinearLayout: Layout {
  /*override public var parentPropertySupportDefinitions: StylePropertySupportDefinitions {
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
  }*/

  @LayoutProperty(\.$direction)
  var direction: Direction

  @LayoutProperty(\.$alignContent)
  var alignContent: Align

  @LayoutProperty(\.$justifyContent)
  var justifyContent: Justify

  var axisIndices: (primaryAxisIndex: Int, secondaryAxisIndex: Int) {
    switch direction {
    case .row:
      return (0, 1)
    case .column:
      return (1, 0)
    }
  }

  var removeWidgetPropertyChangeHandlers: [() -> ()] = []

  func invalidateLayout() {
    container.invalidateLayout()
  }

  override public func setupChildrenPropertyChangeHandlers() {
    for remove in removeWidgetPropertyChangeHandlers {
      remove()
    }

    // DANGLING HANDLER
    /*removeWidgetPropertyChangeHandlers = widgets.flatMap {
      [
        $0.$shrink.observable.onChanged { [unowned self] _ in invalidateLayout() },
        $0.$grow.observable.onChanged { [unowned self] _ in invalidateLayout() },
        $0.$alignSelf.observable.onChanged { [unowned self] _ in invalidateLayout() }
      ]
    }*/
  }

  override public func layout(constraints: BoxConstraints) -> DSize2 {
    let (primaryAxisIndex, secondaryAxisIndex) = axisIndices

    var totalGrowWeight = 0.0
    var totalShrinkWeight = 0.0

    // first pass to get preferred sizes, total grow and shrink weights, determine max cross axis size
    var accumulatedSize = DSize2.zero
    for widget in widgets {
      totalGrowWeight += widget.grow
      totalShrinkWeight += widget.shrink

      var widgetConstraints = BoxConstraints(minSize: .zero, maxSize: .infinity)
      widgetConstraints.maxSize[secondaryAxisIndex] = constraints.maxSize[secondaryAxisIndex]
      widget.referenceConstraints = widgetConstraints
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
      switch widget.alignSelf ?? alignContent {
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

        widget.referenceConstraints!.minSize[secondaryAxisIndex] = constrainedAccumulatedSize[secondaryAxisIndex]
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

      let growWeight = widget.grow
      if deltaAccumulatedSize[primaryAxisIndex] > 0 && growWeight > 0 {
        let relativeGrowWeight = growWeight / totalGrowWeight
        let primaryAxisGrowSpace = deltaAccumulatedSize[primaryAxisIndex] * relativeGrowWeight
        var targetSize = DSize2.zero
        targetSize[primaryAxisIndex] = widget.size[primaryAxisIndex] + primaryAxisGrowSpace
        targetSize[secondaryAxisIndex] = widget.size[secondaryAxisIndex]
        let widgetConstraints = BoxConstraints(size: targetSize)
        widget.layout(constraints: widgetConstraints)
      }

      let shrinkWeight = widget.shrink
      if deltaAccumulatedSize[primaryAxisIndex] < 0 && shrinkWeight > 0 {
        let relativeShrinkWeight = shrinkWeight / totalShrinkWeight
        let primaryAxisShrinkSpace = deltaAccumulatedSize[primaryAxisIndex] * relativeShrinkWeight
        var targetSize = DSize2.zero
        targetSize[primaryAxisIndex] = widget.size[primaryAxisIndex] + primaryAxisShrinkSpace
        targetSize[secondaryAxisIndex] = widget.size[secondaryAxisIndex]
        let widgetConstraints = BoxConstraints(size: targetSize)
        widget.layout(constraints: widgetConstraints)

        widget.referenceConstraints!.maxSize[primaryAxisIndex] = targetSize[primaryAxisIndex]
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
      return widget.margin.left
    } else {
      return widget.margin.top
    }
  }

  func getWidgetEndMargin(_ widget: Widget, _ axis: Int) -> Double {
    if axis == 0 {
      return widget.margin.right
    } else {
      return widget.margin.bottom
    }
  }

  deinit {
    for remove in removeWidgetPropertyChangeHandlers {
      remove()
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
