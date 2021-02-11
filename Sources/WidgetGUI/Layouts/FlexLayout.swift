import GfxMath

public class FlexLayout: Layout {
  override public var parentPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    Experimental.StylePropertySupportDefinitions {
      (ParentKeys.flexDirection, type: .specific(Direction.self))
    }
  }

  override public var childPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    Experimental.StylePropertySupportDefinitions {
      (ChildKeys.flexGrow, type: .specific(Double.self))
      (ChildKeys.flexAlignSelf, type: .specific(FlexAlign.self))
    }
  }

  override public func getBoxConfig() -> BoxConfig {
    widgets[0].boxConfig
  }

  override public func layout(constraints: BoxConstraints) -> DSize2 {
    var maxSize = DSize2.zero
    for widget in widgets {
      var widgetConstraints = constraints
      if widget.stylePropertyValue(ChildKeys.flexAlignSelf, as: FlexAlign.self) == .stretch {
        widgetConstraints.minSize.width = maxSize.width
      }
      widget.layout(constraints: widgetConstraints)
      if widget.width > maxSize.width {
        maxSize.width = widget.width
      }
      if widget.height > maxSize.height {
        maxSize.height = widget.height
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
    case flexDirection
  }

  public enum ChildKeys: String, StyleKey {
    case flexGrow
    case flexAlignSelf
  }
}