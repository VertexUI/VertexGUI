# Creating LeafWidgets

*by example*

**1\. subclass LeafWidget**

```swift
import VertexGUI

// when creating a core Widget you probably need to
// import the specific dependencies instead of the above one
import WidgetGUI // only import when not creating the Widget in the WidgetGUI target
import GfxMath // defines DSize2, DVec2, ...
import Drawing // defines DrawingContext, ...

final class MyCustomWidget: LeafWidget {
  override func performLayout(constraints: BoxConstraints) -> DSize2 {
    // to be implemented
    return .zero
  }

  override func draw(_ drawingContext: DrawingContext) {
    // to be implemented
  }
}
```

`performLayout` and `draw` must be provided.

`performLayout` is used to determine the Widgets size.
You can respect the constraints which the parent Widget will pass to your Widget via the `constraints` parameter, by calling `constraints.constrain(DSize2(yourPreferredWidth, yourPreferredHeight))`.<br>
You can also choose to ignore the constraints which might lead to your Widget overflowing the space that is available and overlapping with other Widgets. Do this by simply returning the size you want the Widget to have `return DSize2(yourPreferredWidth, yourPreferredHeight)`.<br>
The preferred size should be calculated based on the content, so that the content can fit inside the returned size without overflowing.

The size your Widget will have when you choose to respect the constraints passed in depends on the available space and sizes of other Widgets.

In the `draw` method you have access to the final size through the Widget's `self.layoutedSize.width` and `self.layoutedSize.height` properties. Use these values to calculate sizes of the graphics primitives you want to draw.<br>
Nothing prevents you from drawing outside the bounds of the Widget. However when the Widget's `overflow` property is set to `.cut` any pixels outside of the Widget's bounding box will not be displayed.

*details*

[**Overview of the Widget class**](WidgetClassOverview.md)

[**DrawingContext** - documentation](https://ungast.github.io/swift-gui/generated-doc/DrawingContext/)

<br><br>

*more to be added*
