# Architecture Overview

The framework is designed in such a way that it can be used to create applications that are cross-platform. Therefore the framework does not rely on UI components provided by the host environment but draws custom implementations of them directly to the screen.

This leads to the UI looking the same on every platform if no platform-specific design is provided.

To enable the framework for a specific platform a subclass off "VisualApp" has to be created. Implementations for creating windows and receiving input events (mouse, keyboard, ...) and drawing graphics primitves (rectangle, circle, line, ...) need to be provided.

[Note: the way in which platforms are added to the framework will be reworked, therefore not more information is provided here.]

*more information to be added*

<br>

The UI is defined as a tree of "Widgets". Every Widget is a subclass of the core Widget class.

There are so called "LeafWidgets" (subclass of Widget) which define a draw method. This method is automatically called by the framework when the content is to be displayed on the screen.

As the name implies, LeafWidgets are the leafs of the tree. All other Widgets do not define a draw method and instead provide functionality on top of other Widgets. Such a non-leaf Widget might for example be a TextField which provides editing functionality on top of a Text Widget (which is a LeafWidget).

[Note: right now it is not completely true that only LeafWidgets are drawn to the screen. Every Widget can for example have a background color which is automatically applied to fill the bounding box of any Widget. However this is going to change in future versions so that the background is implemented as a child Widget as well. (e.g. a Rectangle Widget with a certain size and color is added as the first child to every Widget which has a Background)]

*details:*

[**overview of the Widget class**](WidgetClassOverview.md)

[**LeafWidgets** - custom drawing logic, how to create them](CreatingLeafWidgets.md)

[**composing Widgets**](ComposingWidgets.md)

<br>

Widgets can be styled in a CSS like manner. You can create your own Widgets by composing core Widgets or creating a new subclass of LeadWidget and define a custom draw method.

*details:* [**styling Widgets**](WidgetStyling.md)

<br>

State can be shared between Widgets directly by passing "Bindings" to child Widgets. There are mutable and immutable Bindings.
Additionally dependencies can be provided by any parent Widget and can be injected into any child (no matter how deep it is nested) on demand.

*details*: [**managing Widget state**](WidgetState.md)

<br>

The approach to handle the global state of the app can be freely chosen. Currently it is recommended to use "Stores" which define a current state as well as mutations and actions to update the state in a transparent manner. They are in concept very similar to [Vuex](https://vuex.vuejs.org/) Stores.

*details:* [**managing global app state with Stores**](GlobalAppState.md)