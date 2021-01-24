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
    - a Widget might make multiple layout requests before the next queue processing happens
    - 