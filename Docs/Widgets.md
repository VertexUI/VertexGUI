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

## Defining the Widget tree

- should the be the option to use slots to provide child Widgets for specific places in the parent Widget?