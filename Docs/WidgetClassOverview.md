*API*

[**Widget** - generated documentation](https://ungast.github.io/swift-gui/generated-doc/Widget)

<br>

# Lifecycle

Every Widget goes through a chain of lifecycle events.

<img src="Assets/WidgetLifecycle.svg"/>

*more to be to this section*

<br>

# User Generated Events

Every class inheriting from Widget (or LeafWidget, ContentfulWidget, because they are subclasses of Widget) allows for registering handlers for a set of user generated events.

These are:
- onMouseEnter
- onMouseMove
- onMouseLeave
- onClick
- onMouseDown
- onMouseUp
- onMouseWheel
- onKeyDown
- onKeyUp
- onTextInput

<br>

To register event handlers on a Widget instance from the outside you can use: `widgetInstance.onSomeEventName(yourHandler)`. This will return the Widget instance which allows for chaining handler registration in the UI tree definition.

You can choose to receive event data as the first parameter in your handler or omit it. The event data is of a corresponding `GUIEventNameEvent` (i.e. `GUIMouseButtonClickEvent`) type and might contain properties such as a position.

Handler registration is internally forwarded to a corresponding `onSomeEventNameHandlerManager` which is an instance property of every Widget. You can also use this to register handlers directly by calling `onSomeEventNameHandlerManager.addHandler(yourHandler)`. This will return an unregister callback, which can be discarded or saved in order to remove the registered handler manually later.

All `onSomeEventNameHandlerManager`s are defined in the [Widget](https://github.com/UnGast/swift-gui/blob/master/Sources/WidgetGUI/Base/Widget/Widget.swift) class, look for the "input events" section.
The mappings from `onSomeEventName` to `onSomeEventNameHandlerManager` are defined in [Widget+inputEventHandlerRegistration.swift](https://github.com/UnGast/swift-gui/blob/master/Sources/WidgetGUI/Base/Widget/Widget%2BinputEventHandlerRegistration.swift).

Direct use of `addHandler` on the corresponding `EventHandlerManager` can be useful when you want to handle events generated on a custom Widget inside your custom implementation. For example:

```swift
class MyCustomWidget: Widget { // or inherit from LeafWidget, ContentfulWidget, ...
  var unregisterKeyDownHandler: (() -> ())? = nil

  public init() {
    super.init()
    // "_ =" means the unregister callback is discarded
    // handleClickEvent will be called every time the user
    // clicks inside the bounding box of a MyCustomWidget instance
    _ = onClickHandlerManager.addHandler(handleClickEvent)
    
    // to store the unregister callback
    unregisterKeyDownHandler = onKeyDownHandlerManager.addHandler(handleKeyDown)
  }
  
  func handleClickEvent(_ event: GUIMouseButtonClickEvent) {
    // do something
  }
  
  func handleKeyDownEvent(_ event: GUIKeyDownEvent) {
    // do something
    // maybe you want to receive only one keyDown event
    // you could then simply call the unregister callback
    // in this handler
    unregisterKeyDownHandler?()
  }
}
```
