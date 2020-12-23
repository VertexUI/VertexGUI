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

<br>

### Passing properties around

<br>

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

<br>

### Collections

<br>

What about properties which have collections as their value? Should there be a special derived type for each of the property types which handles collections? For example there could be a derived type of MutableProperty handling only Arrays. The property could expose a wrapped version of the initial value passed in in which methods like append, remove etc. are intercepted in order to invoke event handlers for these specific types of modifcations. Doing this would allow more efficient updating of Widgets which build their children according to a sequence based data source. That way the already built children can be kept alive and new children have to be instantiated only for the changed items.

Without such a functionality, one would have to resort to comparing the sequences before and after the change and generate events accordingly. It would be necessary for the item type to conform to Equatable in this case. The comparison can also be performed by a dedicated Property, or by the consumer, which receives the old and new values after a change event and can then perform the comparison. Maybe both approaches could be combined.

In the proxy approach an ObservableProperty (which would usually come from a binding to a MutableProperty) could expose the normal collection type. A MutableProperty however would need to expose the proxy type. This is necessary because the standard collection types are structs and not classes and therefore it is not possible to derive from the standard type, overwrite the methods and then cast it down again. For changes to the stored value to be registered by the property, a wrapper struct needs to be created and the user of the property needs to operate on this wrapper/proxy. It should however behave like a normal type of that collection.

Is it feasible to have custom collection types that must be used instead of the standard ones? Well the data must be stored and created somewhere. If the data is created and stored locally inside a Widget and maybe passed to some child Widgets, it is fully possible to define the property with the custom wrapper type. Also: the normal data type can be accessed through the wrapper. That means on any change event the whole underlying sequence can be used as well if it is required to pass a standard type somewhere. Another place the data might come from is a store. The properties in the store state should probably be defined as special reactive store properties where the invocation of event handlers can be delayed until all modifications have been made. The modifications are defined in the form of actions which might lead to the change of specific items inside a collection property. In such a case it is as well possible to define the property with a custom data type. The only thing is: if for some reason the whole collection value of the reactive property needs to be replaced, and the data for the replacement comes in the form of a standard collection type, this data would first need to be manually wrapped to perform an assignment operation, since inheriting relationships are not possible.

An option to circumvent this is could be to define the wrappers as classes, then make the wrappedValue of the reactive property immutable which will only allow modification of the underlying value by calling methods on the wrapper. Therefore something like a replace method would need to be added to the wrapper. However this does not reduce the number of steps the user has to take for a full replacement and adds the weight of a class data type for values that would probably better be structs.

### Optionals

And what about optional values? How does a collection property handle optional types? How do reactive properties in general handle optional types?

For normal property types, optionals should not be any different from non optional types in the way they are handled (maybe there are differences for ComputedProperty). For collection property types, allowing optionals would mean that when the handlers on the proxy object would need to be reattached every time the value is set from nil to something. And how to define the optional type? The reactive collection property will define the type of the exposed value. Which will be the proxy type. And which will not be optional. It could be somehow possible however to let the wrapper handle optionals. But then, isn't the absence of any items in a collection enough to signify absence of a value?

<br>

### Computed properties

<br>



