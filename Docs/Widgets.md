
# Widgets

This document serves as a reference for implementation.

## Composing Widgets

Thinking through the composing architecture with a focus on styling.

- complex Widgets are composed out of simpler Widgets
  - for example a Container Widget provides functionality such as applying a padding and a background, which is reflected in it's style properties
  - therefore the Container Widget must be able to inherit style properties from it's children, to simplify the setting of properties for the user
  - this can be done by using protocols such as AnyPaddingStyleProperties
- should Widgets be composed out of another?
- there are two sides to the development
  - core development: thinking about which Widgets are necessary to create any type of application and implementing them in an easily accessible way with a great api
  - user development: implementing special Widgets for special needs which may provide extravagant appearance or optimized performance for a specific type of visualized data, special effects etc.
    - users might want to create their own libraries out of special Widgets to share them with the community and/or reuse them in other products
    - ==> it must be possible to access all the types from the core framework that are necessary to create new Widgets at a low level and provide a great api
    - there are different levels of complexity with which new Widgets would be created
    - most new Widgets will be compositions of core Widgets, that do not need to provide a custom styling api, but will be semantic wrappers around a tree of widgets, using cascading styles with the core Widget styling api is enough for this case
      - an example of this might be a MenuWidget which uses a core List Widget for the menu entries, an Icon Widget to show a users avatar, a Button Widget to enable a click action on the avatar icon which opens another page, etc., the whole Widget can get a class and if it needs to be styled in a special way any where in the application, nested styles which apply to the individual core Widgets can be used
        - or can it be different?
        - the core styling approach might be sufficient for such a Widget at the beginning, but the developer might find that there are lots of places in the application, where the Widget needs to appear slightly different
        - one way to do this would be to apply flags/class-flags to the Widget in the respective places and then the internal styles which the developer defined when creating the Widgets correspond to these classes/flags and the style is adjusted
        - that is however limited in the way that no concrete values like colors can be passed in, instead each color would have to get it's own class
        - another way would be to pass these concrete values to the initializer of the Widget and then generate styles within the initializer, now there can be sophisticated variations in the look of the Widget at various places, however it can only be styled directly wherever the instance is created and not in a separate stylesheet
        - another way, staying with the core styling approach would be to make a style generator for this specific widget, and at whichever place the styles of the Widget should be defined, insert the output of this generator which takes input in form of concrete values which control the output, Advantages: sophisticated variations, at any place in the code, disadvantages: whoever uses the Widget needs to know there is a generator and can't simply see that is is a StylableWidget which defines a Style type, if the Styles are to be defined inside a stylesheet, a file with a different file format which is then parsed into Style instances by the application (useful to allow end users to style the application), having a generator generate styles would need to be implemented into the parsing logic by the application developer, if generators are not a part of the core, the other parsing logic of instantiating the correct Style types with selectors and properties can be done by the core and be usable in any application
        - another way could be to define a custom StyleProperties type for the composed Widget which defines non-default properties that do not occur in other Widgets but might also include default properties if it makes sense
          - when doing this for the MenuWidget, one could define a property like: highlightType (enum: triangle, square, background) --> defines how the selected menu item is highlighted (note: one could argue that this is a property which should be defined when creating the instance of the MenuWidget, but making it stylable would definitly be convenient and speed up changing the look of the application, because these style properties can be applied to multiple instances of MenuWidget at once e.g. by using class selectors), and in comparison with using class flags, providing a color value or image value to the enum value background would be possible here which is much more useful than just having flags
    - other Widgets will be more complex, maybe even don't use any core Widgets to build there functionality and instead implement it from scratch but styling


## Theming and updating styles when theme variables change (during runtime)

## Handling styles that change the size and layout of Widgets