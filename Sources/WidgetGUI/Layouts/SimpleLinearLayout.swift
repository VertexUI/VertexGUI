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

    // first pass to get preferred sizes, determine max cross axis size
    var accumulatedSize = DSize2.zero
    for widget in widgets {
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

    let constrainedAccumulatedSize = constraints.constrain(accumulatedSize)
    let deltaAccumulatedSize = constrainedAccumulatedSize - accumulatedSize

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

    // TODO: resolve main axis
    // --> note, e.g. for image view, it might have been stretched, and now, it might be shrunk again and the height will shrink as well
    // because it has aspect ratio -> so stretch will not work, that's ok!

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
    case alignSelf 
  }
}