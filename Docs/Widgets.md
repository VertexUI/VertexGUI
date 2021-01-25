# Widgets

This document serves as a reference for implementation.

## Composing Widgets

- there are different types of Widgets
  - leaf Widgets
    - do not have children
    - usually output something renderable
    - e.g. Text, Icon, ...
  - layout Widgets
    - can have one or many children
    - usually do not output something renderable themselves
    - e.g. Column, Row, ...
  - functional/meta Widgets:
    - offer functionality such as receiving mouse events
    - could modify the rendered output of their children (e.g. translate)
    - could add renderable output
    - e.g. Container (background, foreground, padding, ...)
  - composed Widgets:
    - can have one or many children
    - provide functionality by building on other Widgets
    - can add own functionality and renderable output
    - e.g. Button can contain Text, Icon ..., ListItem can contain Text, Icon, Image, anything else ...

- which types of Widgets does the framework need to provide and how can they be composed to create any required functionality?
  - currently there are separate Widgets such as Padding, Background, etc.
  - these might be merged into one Widget which provides all of these properties => Container
  - this would also reduce the amount of Widgets in the tree which could increase performance
  - a question is, whether to still keep these Widgets and maybe compose the Container Widget out of them, or whether to remove them alltogether
  - using them internally would increase the amount of Widgets in the tree and offer no benefit if they are not used on the outside as well
  - maybe some users want to create their own Widgets which provide padding functionality but no background functionality
    - is this even allowed, or should every Widget be able to provide a background?
    - maybe (almost) every Widget should, maybe not, maybe every Widget subtree that requires such functionality should be wrapped inside a Container Widget which provides this functionality
    - until it is evident that certain properties need to be available on every Widget, they should be kept optional, applyable through wrappers
    - so a padding should probably be optional as well
    - maybe it should be stated in the documentation, that certain functional Widgets should only be used internally and if the functionality is required in the tree, just use the Container Widget
  - how to compose Widgets may depend on how styling should happen
    - a composed Widget like a button should be stylable with a background, a padding and a foreground color, the background could be implemented by the button or through a background Widget, as well as the padding, maybe the whole button should be implemented as a container with special functionality
    - 

<br>

## Defining the Widget tree

- should the be the option to use slots to provide child Widgets for specific places in the parent Widget?

<br>

## Lifecycle

<br>

### current implementation

- build
- mount
- boxConfig
- layout
- render

<br>

### what is the goal?
- go from the instantiation of a Widget with it's respective parameters to a renderable output of each Widget
- react to changes in the data, Widgets may change in size, layout of children, appearance (e.g. colors), be removed or be added dynamically inside the tree
- handle all updates efficiently, only do the calculations that are necessary to process the update, avoid side effects leading to unnecessary recalculations

<br>

### what needs to be considered?
- certain changes require different updates of the widget (e.g. relayout and rerender, only rerender)
- there needs to be a way to debug the Widget tree and all the calculations which happen as well as the triggers that happen

<br>

#### updating the tree when data changes
- there are at least two ways this can be implemented:
- every Widget has a build function which instantiates all the children that Widget should have
  - if a Widget receives children from the outside during it's instantiation, these should be received as a builder function
  - the builder function should be stored by the Widget to be reused later
  - when the Widget is rebuilt, the builder function is called again
  - if the builder function contained some conditions, depending on variables of an outside scope, these conditions are reevaluated and therefore the instantiated children may change
  - a rebuilt could be triggered by:
    - providing a set of dependencies (e.g. in the form of ReactiveProperties) with the build function or in the Widget's initialization
    - listeners are attached to them by the Widget
    - automatic recording of dependencies of the build function could be possible as well (in some cases)
    - a function for invoking a rebuild is provided as well and can be called on the Widget instance directly
- only certain Widgets actually rebuild their children/create new instances
  - for other Widgets, rebuilts are disabled/or run without an effect
  - Widgets such as the Build Widget or a dynamic List Widget, which depend on ReactiveProperty inputs, manually implement the logic for updating their children
  - if it is required to rebuild certain Widgets conditionally / build different Widgets based on some condition in some composed Widget, Widgets such as the Build Widget are used as wrappers
  - the Build Widget should forward all layout and style properties to the built child, it should not add any rendered output / modify anything else
  - how could this different handling for different Widgets be implemented?
    - there might be a flag on each Widget "rebuildable" (or other name), which indicates whether rebuilds are supported or not
    - the build() function checks upon invocation, whether this flag is set to true
    - if not, whether this is the first build or not, if it is not, then just return without doing anything, maybe throw a warning
    - if the Widget is rebuildable, performBuild() is called again

<br>

#### mounting, remounting, getting access to context and parent information
**add content**

<br>

#### destruction
- a Widget that is no longer needed needs to be destroyed, in order to delete all event handlers the Widget registered or that are registered on the Widget
- as well possibly freeing the render state
- properties that are managed/created by the Widget should be destroyed as well
- because there might be handlers registered on them that capture the Widget instances
- so, the main reason for doing active removal of handlers etc. is to ensure that the Widget instance itself is not captured anywhere, which would lead to the memory not beeing freed
- however it cannot be fully ensured, that outside code is not holding a reference to the Widget
- actually this might even be very common when the debugger is active, since past requests and logs are stored which might include a reference to the Widget
- maybe it would be useful to have an unowned Array of all Widgets, Widgets should register themselves there on instantiation
- this array could then be displayed in the debugger, after all logs are manually deleted, to see which Widgets are not deleted and for which there must be a reference that was not cleared somewhere in the code
- after a Widget was destroyed, it shouldn't be possible to mount, render, layout or do anything else with the Widget
- instead an error should be thrown if any of these methods is invoked
- this should help with finding places where references are unintentionally holding the Widget in memory as well

<br>

### How to handle registration of children?
**Implement children as an iterator provided by subclasses?**

<br>

### some examples?
- Button Widget
- List Widget
- ScrollArea Widget
- Transition Widget (optional for now)

**add content to examples**

<br>

### implementation approaches

**what kinds of updates to a Widget are necessary?**
- the Widget needs to be mounted to it's parent, receiving information such as a Context
- the children of a Widget need to be built (passing on scope information) and mounted and their children need to be built as well
- matching styles need to be determind, registered, merged and evaluated
  - there are two parts here:
    - the styles are applied by global logic to each individual Widget
    - each individual Widget handles the merging and evaluation of the styles by itself (currently)
    - maybe there should be a request for fetching styles, one for merging them and a function that acutally does the merging
- the Widget needs to be layouted
  - positions of children are determind by getting their size first by calling layout on them with constraints
  - and then calculating the positions of all children based on their sizes
  - **currently** there is a sort of layout preflight request which retrieves information about a preferred size, min size and max size from child Widgets (recursively)
    - this might help to reduce the number of layout calls sometimes
    - for example when deciding whether to do a line break in a row, it would be sufficient to look at the min size of a child to determine whether the break is necessary now
    - otherwise the child would have to be layouted with constraints that might be to tight, the output size of the Widget would overflow the available space
    - a break would be introduced and the Widget would be layouted again with new constraints
    - this might be a possible, simpler implementation as well
- they need to be rendered: rendering children recursively and adding own content on top
  - after certain changes, the rendering needs to be updated
- they might need to be unmounted
  - **currently not implemented**
  - might be useful to move Widgets around in the tree, without destroying and reconstructing them
  - provide defined behavior when the parent, context information are removed from a Widget
- they need to be destroyed

<br>

#### **more detailed information about each lifecycle method**

**add content**

<br>

#### **how to call (name) these updates (common category)?**
- lifecycle method
- lifecycle handler
- lifecycle hook
- some name with "lifecycle" is probably appropriate
  - because the updates can be cyclical
  - and the "life" of a Widget starts with one of these methods and ends with one of them (build --> destroy (or other names))

<br>

#### **in general**
- the current approach of Widgets passing messages through a bus will probably be continued
  - advantages:
    - it enables delayed and batch execution, avoiding unnecessary calculations in short temporal distance (where the previous ones get overwritten by the last one --> do only the last one)
    - **are there more advantages?**
  - disadvantages:
    - Widget does not have immediate full control
    - when requesting updates in the Widget it has to be taken into account, that the update will be executed at a later point in time
    - **are there more downsides?**

<br>

#### **for debugging:**
  - for each update request that a Widget sends, the reason must be known
  - since the functions are not invoked directly, but later, by going through a queue, the standard debugger won't show a useful call tree
  - furthermore such a calltree would not show which instance of a Widget triggered something
  - example: **layout**
    - a layout request will be sent by a Widget if
      - the size of a child changed
      - a child got added or removed
      - a parameter influencing the layout changed (e.g. flex orientation)
      - possibly more reasons
    - there should probably be an enum that is passed with every layout request which specifies the reason
    - a Widget might make multiple layout requests before the queue is processed

          Widget {
            private layoutInvalid = false

            build() {
              ...

              for child in children {
                child.onSizeChanged {
                  invalidateLayout(.childSizeChanged(...))
                }
              }
            }

            invalidateLayout(reason: LayoutInvalidationReason) {
              if layoutInvalid {
                return
              }

              layoutInvalid = true

              requestLayout()
            }

            requestLayout(reason: LayoutInvalidationReason) {
              bus.publish(LifecycleRequest(.layout(reason), self))
            }

            layout() {
              // perform the layout operations
              ...
            }
          }

          enum LayoutParameterChangeReason {
            stylePropertyValueChanged(name)

            // the property that defines the value changed, e.g. a new style got applied and overwrites the previous property
            resolvedStylePropertyChanged(old, new)
          }

          enum LayoutInvalidationReason {
            layoutParameterChanged(name, oldValue, newValue, reason: LayoutParameterChangeReason)

            childSizeChanged(child: Widget, oldSize, newSize)

            other(description)
          }

  - example: **render**

        class Widget {
          
          invalidateRendering(RenderingInvalidationReason) {
            ...
          }

          requestRendering(RenderingInvalidationReason) {
            bus.publish(LifecycleRequest(.render(reason), self))
          }

          render() {

          }
        }

        enum RenderingInvalidationReason {
          sizeChanged
          renderingParameterChanged(reason: ...)
          other(description)
        }

  - when a Widget is selected in the debugger, a stream of requests and reasons can be shown
  - for each type of request and reason, the debugger would need to define a way to visualize it --> should be easy using switch (enumValue)
  - another useful metric would be actual invocations of lifecycle methods, instead of only the requests
  - since the invocations are made because of requests, the reason for each invocation should be known
  - the debugging information about the calls of the lifecycle methods can probably be generated by the root level lifecycle logic, since the Widget should (probably) never call it's lifecycle methods by itself
  - should this change and Widgets do call their lifecycle methods by themselves, it would be possible to add a reason parameter to every lifecycle method and let the method generate the debug information and pass it up through a bus as well or just provide the data via an event manager
  - probably the approach of adding the parameter is necessary, because for example the layout logic calls the layout function on every child during the layout of the parent
  - so a reason like: firstLayoutPass or layoutByParent(parent) could be passed in
  - a useful metric would be the times at which requests were made, the invocations started and ended, maybe in terms of ticks
  - for this two separate messages would need to be sent, and then be merged to one event by the debugger or somewhere else in the logic
  - one could then inspect how long it took and what happened inbetween (which requests, other invocations were made)
  - the sending of messages could look like this:

        layout(constraints, reason) {
          var currentInvocationId = nextInvocationIds[.layout]
          nextInvocationIds[.layout] += 1

          lifecycleInvocationBus.publish(.started(.render(reason), self, currentInvocationId, currentTick))

          // ... perform layout

          lifecycleInvocationBus.publish(.ended(.render(reason), self, currentInvocationId, currentTick))
        }

        // somewhere else
        getInvocationStartEndMessagePairs() {
          foreach message1, message2 in messages {
            if message1.sender == message2.sender && message1.invocation == message2.invocation && message1.invocationId == message2.invocationId {
              return (message1, message2)
            }
          }
        }

  - maybe the reasons for the invocation should not be associated values of the invocation type enum? to enable simpler comparison and using the invocation type as dictionary keys
  - maybe InvocationReason should be an own type, and there should be enums that conform to this type for every type of invocation, each enum might then define cases such as .request(request), .byParent(parent) etc.

#### **tips for implementing**
- implement a generic Bus system with piping, filtering (warning about dropped messages), etc.
- at first, all of these things can probably be implemented on top of the current system, purely as information for debugging
- the switch to use the new requests in the root logic can be made later