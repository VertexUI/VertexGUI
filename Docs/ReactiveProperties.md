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
