# Reactive Properties

This is the design document for reactive properties. Used as a reference for implementation.

<br>

## Types of reactive properties

<br>

### StaticProperty

- used if some kind of reactive property is required as argument type, but it is already known that it will never change

<br>

### ComputedProperty

- value calculated by a function
- `get` access only
- can depend on other reactive properties for it's calculation (if those change the ComputedProperty might change as well)

<br>

### MutableProperty

- actually stores a value
- `get` and `set` 

<br>

### MutableComputedProperty

- value calculated by a function
- `set` is handled by a user defined function as well
- can depend on other reactive properties like ComputedProperty
- if `set` is called, dependencies might be changed which would trigger an update of the properties value
- it could also be that no (reactive) dependency is modified, in that case **should the value always be updated after set?**

<br>

## What might an implementation look like?

  A widget that only needs read access to a reactive property in order to update itself on changes. Examples might be a Text Widget and an Image Widget.

    SomeWidget.init(argument1: ObservableProperty<ArgType1>) {
      self.property1 = argument1
      argument1.onChanged(update)
    }

`ObservableProperty` is the type that all reactive properties conform to.

**==> class based or protocol based?**

In the example above the Widget would receive the property directly, with all the event handlers attached to it at other places in the code, outside of the widget. Because the property has functions like removeHandlers()/destroy() which need to be called to ensure that no objects are kept in memory because they are caught in the closures of the handlers.

What might an actual case of this look like?

    // Widget1
    class Widget1 {
      @MutableProperty
      var property1: Bool = false

      onSomeEventTheUserInitiates() {
        property1 = true
      }

      build() {
        Column {
          ...
          Widget2(argument1: property1)
        }
      }

      destroy() {
        property1.destroy()
      }
    }

    // Widget2
    class Widget2 {
      @ObservableProperty
      var property1: Bool

      init(argument1: ObservableProperty<Bool>) {
        property1 = argument1
        property1.onChanged(update)
      }
    }

In this example the ObservableProperty is a `bool` flag which might decide over the contents of Widget2 but is controlled by Widget1. If Widget1 is destroyed, Widget2 should be destroyed as well, but the handler to property1 captures self (Widget2), so that Widget2 is destroyed() but deinit is not called and the memory is not freed. One solution would be to call destroy() on the property in Widget1's own destroy() routine. However Widget2 would have access to this function as well and if Widget1 has handlers registered on property1 as well, those might be destroyed if Widget2 is destroyed but Widget1 isn't.

One solution to this could be to pass a derived property to Widget2. So that Widget2 can safely destroy that derived property without anything changing for Widget1. To avoid unnecessarily hard to track down bugs, the type system should be used to enforce a derived property being passed in. And it should be impossible to use the derived property type directly as a property wrapper to prevent users from doing this and then passing the derived property to the other Widget directly.

How could this be achieved? One possible result could look like this:

    class Widget1 {
      @MutableProperty
      var property1: Bool

      build() {
        Widget2(property1.observableBinding) // if the other widget requires a mutable, use .mutableBinding
      }
    }
    
    class Widget2 {
      @ObservableProperty
      var property1: Bool

      init(_ property1: ObservablePropertyBinding<Bool>) {
        self._property1 = property1
      }
    }

This would require that ObservablePropertyBinding is derived from ObservableProperty, in that case, only classes may be used for the property types.

Another approach could be to let the Widget receiving the property handle the deriving.

    class Widget1 {
      @MutableProperty
      var property1: Bool

      build() {
        Widget2(property1)
      }
    }

    class Widget2 {
      @ObservableProperty
      var property1: Bool

      init(_ property1: ObservableProperty<Bool>) {
        self.property1 = property1.deriveObservable()
      }
    }

In either case the author of the Widget receiving the property must take action to ensure that the property is not directly taken in but wrapped, either by only accepting a binding or by deriving an observable from it.

What about properties which have sequence properties as their value?


