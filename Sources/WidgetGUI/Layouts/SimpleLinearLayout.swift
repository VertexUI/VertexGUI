import GfxMath

public class SimpleLinearLayout: Layout {
  override public var parentPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    Experimental.StylePropertySupportDefinitions {
      (ParentKeys.direction, type: .specific(Direction.self), default: Direction.row)
    }
  }

  override public var childPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    Experimental.StylePropertySupportDefinitions {
      (ChildKeys.grow, type: .specific(Double.self), default: 0.0)
      (ChildKeys.shrink, type: .specific(Double.self), default: 0.0)
      (ChildKeys.alignSelf, type: .specific(Align.self), default: Align.start)
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
      widgetPosition[primaryAxisIndex] = accumulatedSize[primaryAxisIndex]
      widgetPosition[secondaryAxisIndex] = 0
      widget.position = widgetPosition

      accumulatedSize[primaryAxisIndex] += widget.size[primaryAxisIndex]
      if widget.size[secondaryAxisIndex] > accumulatedSize[secondaryAxisIndex] {
        accumulatedSize[secondaryAxisIndex] = widget.size[secondaryAxisIndex]
      }
    }

    var constrainedAccumulatedSize = constraints.constrain(accumulatedSize)

    // resolve cross axis
    var currentPrimaryAxisPosition = 0.0
    for widget in widgets {
      widget.position[primaryAxisIndex] = currentPrimaryAxisPosition

      var needRelayout = false
      var widgetConstraints = BoxConstraints(minSize: .zero, maxSize: .infinity)
      widgetConstraints.maxSize[secondaryAxisIndex] = constraints.maxSize[secondaryAxisIndex]

      // TODO: implement property definitions forwarding to children!
      switch widget.stylePropertyValue(ChildKeys.alignSelf, as: Align.self)! {
      case .start:
        widget.position[secondaryAxisIndex] = 0
     
      case .center:
        widget.position[secondaryAxisIndex] = constrainedAccumulatedSize[secondaryAxisIndex] / 2 - widget.size[secondaryAxisIndex] / 2
      
      case .end:
        widget.position[secondaryAxisIndex] = constrainedAccumulatedSize[secondaryAxisIndex] - widget.size[secondaryAxisIndex]

      case .stretch:
        needRelayout = true
        widgetConstraints.minSize[secondaryAxisIndex] = constrainedAccumulatedSize[secondaryAxisIndex]
        widgetConstraints.maxSize[primaryAxisIndex] = widget.size[primaryAxisIndex]
      }

      if needRelayout {
        widget.layout(constraints: widgetConstraints)
      }

      currentPrimaryAxisPosition += widget.size[primaryAxisIndex]
    }

    accumulatedSize[primaryAxisIndex] = currentPrimaryAxisPosition
    constrainedAccumulatedSize = constraints.constrain(accumulatedSize)
    let deltaAccumulatedSize = constrainedAccumulatedSize - accumulatedSize

    // resolve main axis
    currentPrimaryAxisPosition = 0
    for widget in widgets {
      widget.position[primaryAxisIndex] = currentPrimaryAxisPosition
 
      let growWeight = widget.stylePropertyValue(ChildKeys.grow, as: Double.self)!
      if deltaAccumulatedSize[primaryAxisIndex] > 0 && growWeight > 0 {
        let relativeGrowWeight = growWeight / totalGrowWeight 
        let primaryAxisGrowSpace = deltaAccumulatedSize[primaryAxisIndex] * relativeGrowWeight
        var targetSize = DSize2.zero
        targetSize[primaryAxisIndex] = widget.size[primaryAxisIndex] + primaryAxisGrowSpace
        targetSize[secondaryAxisIndex] = widget.size[secondaryAxisIndex]
        var widgetConstraints = BoxConstraints(size: targetSize)
        widget.layout(constraints: widgetConstraints)
      }

      currentPrimaryAxisPosition += widget.size[primaryAxisIndex]
    }

    accumulatedSize[primaryAxisIndex] = currentPrimaryAxisPosition

    return accumulatedSize 
  }

  public enum Direction {
    case row, column
  }

  public enum Align {
    case start, center, end, stretch
  }

  public enum ParentKeys: String, StyleKey {
    case direction
  }

  public enum ChildKeys: String, StyleKey {
    case grow
    case shrink
    case alignSelf 
  }
}