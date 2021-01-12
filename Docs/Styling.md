# Styling

This document serves as a reference for implementing the styling API of the framework. It will later help to provide documentation.

<br>

## Targetted Syntax

    Main {
      // the styles inserted by StyleProvider should only be checked for a
      // selector match with the children of StyleProvider, Widgets outside of it
      // remain unaffected by the provided styles,
      // even if their selectors match
      StyleProvider {
        Text.Style(".button-text") {
          $0.fontSize = 16
          $0.fontWeight = .bold
          $0.foreground = .black
        })

        Button.Style(".default-button") {
          // this transition means: whenever the active style is this one,
          // start a transition of the given duration towards the currently
          // active background fill
          $0.backgroundTransition = Transition(duration: 0.1)
          // .background should be a property of type Fill, which is a protocol that Color, Gradient, Image, ... should conform to
          $0.background = Color.blue
        }.sub {
          // append nested styles that are only checked for a match when the parent selector matches

          // & means: extend the parent selector by what follows after &
          // :hover means: pseudo class hover, that is available on Button
          Button.Style("&:hover", Button.Style) {
            $0.backgroundTransition = Transition(duration: 0.2)
            $0.background = Color.red
          }.sub {
            Text.Style {
              $0.foreground = .white
            }
          }

          // it should be possible to perform matching by checking all
          // Widgets with a custom match function
          Button.Style("&:hover", { ($0 as? Button)?.text == "button1" }) {
            // the transition defined in the $:hover style above should apply here as well,
            $0.background = Color.orange
          }.sub {
            Text.Style {
              $0.foreground = .yellow
            }
          }

          // The StyleContext object should provide an easy way to access all the other
          // styles that apply to the same element as this style, handling overwriting by preferring later definitions over earlier definitions on a per property basis.
          // Whenever a style in the context is updated, removed, added, the following style needs to be recomputed. If other styles depend on it
          // these will then also be recomputed.
          Button.Style("$:active") { (context: StyleContext) in {
              //context.get(AnyStyle.self) should go through all styles that apply to this element before the current style and look for any styles that conform to BackgroundStyle and return the merged properties as an AnyBackgroundStyle 
              // the context should store information about which styles were accessed and therefore are dependencies of this style
              // use this information to reduce number of unnecessary rebuilds (e.g. a parent is updated but it is anyway of a different type, or anyway overwritten by the children or something like that)
              $0.background = (context.get(BackgroundStyle.self, AnyBackgroundStyle.self)?.background as? Color)?.darken(10) ?? Color.red
            }
          }.sub {
            ...
          }

          // ForegroundStyle and BackgroundStyle should be protocols
          // which elements like Text, Button conform to. If only the properties
          // need to be set, on a selector which selects different types of elements, 
          // use the AnyStyleProtocol struct implementation of the protocol.
          // The Widget should accept these basic types as styles and apply them.
          AnyForegroundStyle(".foreground-highlight) {
            $0.foreground = .red
          }

          AnyBackgroundStyle(".background-highlight) {
            $0.background = .blue
          }
        }
      } {
        Column {
          Button {
            Text("button1").with(class: "button-text")
          }.with(class: "default-button")

          Button {
            Text("button2").with(class: "button-text")
          }.with(class: "default button")

          Text("This is a description.").with(class: "description").with(style: Text.Style {
            $0.fontSize = 18
            $0.fontWeight = .normal
          })

          Card {
            Row {
              Icon(...).with(class: "foreground-highlight")
              Text(...).with(class: "foreground-highlight")
            }

            RichText { ... }

            Text(...).with(class: "background-highlight")            
          }
        }
      }
    }

<br>

## Overview

- there are structs(? or classes) for each Widget which define the stylable properties of the Widget
- a StyleProvider Widget provides such styles to all it's children and only to it's children, siblings are unaffected
- the styles are distributed according to selectors which contain classes, pseudo-classes and probably more
  - classes which are strings (can e.g. use enums to get autocomplete), classes can be assigned to the Widgets from the outside when instantiating them or really at any point in time probably
  - pseudo-classes are strings as well and are internally exposed by the Widget according to it's own state
  - a function can be applied to each style definition that checks each Widget that passes the selector for other things that are better checked by a function and only if this function returns true, the styles are applied to the Widget
- there are protocols which contain properties that many Widgets share, e.g. ForegroundStyle
  - the specific Widget styles implement these protocols and provide the described properties, e.g. a TextStyle which conforms to ForegroundStyle provides a property "foreground"
  - there are direct implementations of these shared styles as well which can then be applied to many different Widgets which don't share their main style definition (e.g. Text and Icon can both receive a ForegroundStyle instead of their specific TextStyle or IconStyle)
- styles have sub styles, the selectors of the sub styles are appended to the parent and checked only if the parent matched first
- a Widget can receive multiple styles, depending on how many selectors match the Widget
  - the styles are in the order in which they occur in the definition of the Widget tree
  - the Widgets needs to go through all styles and check whether it accepts the given object (is it of an accepted type?)
  - and then merge all the properties together, later definitions overwriting previous definitions, and apply them to itself
- there are reactive style definitions, which receive a context through which they can access all earlier defined styles which match the Widget they match
  - the information about the parent styles can then be used to provide a computed style
  - whenever a parent changes, it must be checked whether the computed style needs to be updated (track dependencies)
  - if it updates and is changed, all other computed styles which depend on this one must update as well

<br>

## Styling composed Widgets

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
    - other Widgets will be more complex, maybe they do not even use any core Widgets to build there functionality and instead implement it from scratch but need to provide the same styling properties as some core Widgets
      - take for example custom ToggleButton in the style of an iOS ToggleButton, it could have styles such as: background (core), toggleAnimationDuration ()
      - the core styles could be added with protocols such as AnyBackgroundStyleProperties, but why would that be necessary? for the type? or is it enough to use the same name? why would core compatibility be needed at all? all properties could be handled as properties unique to this Widget
    - should the styling be simplified to provide a set of common properties that every Widgets StyleProperties needs to define? 
      - such properties could be padding, background, foreground, fontSize, margin
      - this could be realized by adding these properties to the AnyStyleProperties protocol
      - this would lead to all of these properties needing to be defined in every implementation of StyleProperties of any Widget
      - maybe the StyleProperties protocol can be changed to enforce every implementation to define a property dictionary, keyed by a string name and accept any value and then implement every property as a computed property, in that way, the default shared properties could be added to every implementation by providing default implementations in the protocol extension
      - another approach could be to define sets of shared properties, which implementations can conform to if the developer thinks, that this Widget whould accept certain default properties
      - the default properties could then be set, regardless of the specific StyleProperties implementation, with a default implementation which defines all kinds of shared properties, the merging logic will then filter away any properties that are not present in the specific StyleProperties
      - if the layout relevant properties are as well included in the style properties and the approach of adding some default properties to all implementations is taken, it might be necessary to extend the set of default properties if a developer defines a custom layout and wants to add it's specific properties to all existing implementations of StyleProperties
        - can this be done with protocol extensions?
        - after some tests, implementing this with protocol extensions would bring up the need to write a dedicated property getter and setter referencing the shared storage for every new property, which would propbably be ok
        - this would only be necessary for properties that need to be added to every type of StyleProperties
        - for StyleProperties that only need to work for a specific kind of Widget, it would be ok to continue to use variables with property wrappers in structs, when iterating through the properties, to merge them, the check for whether it is a property wrapper would have to be modified to also include the pure getter, setter implementations and leave out the storage variable

        - **are other approaches than a struct with variables approach possible?**
          - that allow for adding global properties that can be applied to any Widget
          - and provide a way to create specific properties which apply to specific Widgets
          - an other approach could be to use enum keys with a dictionary
            - style properties are dictionaries, keyed by enum properties and the values are of type StyleValue (Protocol) and need to be cast to the respective types by some other logic
            - the enum keys should resolve back to strings, there could be an enum for default properties that can be applied to any Widget by providing a global enum
            - ~~such an enum could also later be extended with extensions~~
            - no, extending enums with keys is not possible, one can either use static values on some struct, but this makes it hard to check whether a key is supported by doing backwards querying, or by using many enums, which makes it hard to check whether a key actually exists as well
            - for styles that only apply to specific widgets, an enum could be added to that Widget which contains the keys for the specific properties
            - by using enums, one can use autocomplete to find available properties quicker
            - since the keys are strings and the values conform to a special protocol, serialization should be easy, and reading style sheets from plain text is possible
            - having the split between default properties and and special Widget properties seems reasonable
              - a user will first access defaultEnum.case for all the common styling options
              - and if he wants to style something that seems to be tied to the functionality of that specific Widget and he hasn't seen in other Widgets, he will look at Widget.StyleEnum to find appropriate properties
            - maybe there is no necessity to provide a default enum?
              - maybe all keys can belong to Widgets, such as the layout Widget which the current Widget is inside, or the Container Widget which applies things like background, padding, etc.
              - determine this in the code/syntax example
            - a disadvantage could be that the values for the properties are not fully checked by the compiler as any value conforming to StyleValue is accepted
            - a question is how much complexity to add to the logic for accepting and applying the styles
            - the values need to be read according to their specific keys at the place they are necessary, checked for their type and then applied
            - if the type isn't right, a question is whether to crash or to simply ignore the value and provide a warning
              - in debug mode it would probably be good to crash
              - and in production to simply provide a warning
            - reading: the values might be read by the Widget the styles are applied to, in order to change it's own appearance
            - or it might be read by a parent Widget, e.g. a layout Widget which wants to know how the Widget wants to be positioned 
            - it could be useful to allow for multi specification of property values, by providing each property as a tuple of key and value and creating an array instead of using a dictionary directly
              - when could this be useful?
              - **continue here**
            - could associated values be used as well? associated values would make merging and serializing more difficult, because special functions would need to be provided to handle newly added associated value cases
            - a question is whether the style properties should be wrapped in dedicated structs for each Widget or the pure dictionaries in combination with a selector and sub styles would be sufficient
            - how could the syntax be the most user friendly?:

    Column {
      Style(".action-button", [
        (.background, Color.red),
        (.foreground, Color.)
      ])

      Button(class: "action-button") {
        Text("some action")
      }

      Button(class: "support-button") {
        Text("some supporting action")
      }
    }

- there should be an option to use enum cases as classes, so the value for class should be a protocol of type ClassKey or something which String and the Enums conform to
- where should the styles be provided?
  - inside the Widget tree?
    - inside the child builders
    - or by calling another function / using another builder on the Widgets
  - or outside?
- should every Widget accept styles?
  - probably yes, because every Widget needs to be layouted and can for example receive style properties relevant for positioning in flex contexts
- how to check for whether a key is supported or not in this approach?
  - this would be necessary to enable notifying the developer that a cetrain property does not exist ==> going with the string key/enum value or wherever the keys come from can reduce the automatic checking for errors / non existing things when nothing is done to take care of this
  - to check for the existance of a key, all existing keys need to be known to the framework (when the checking is done by the framework)
    - the checking could also be done by each Widget, the author of the Widget could write a function which tests each key for existance
    - but it would probably be enough to give the framework a bucket of keys which are all accepted and let the framework handle the checking
    - if the approach of letting parents access styling properties on the child is taken, the accepted keys are also determind by the parent
    - so either the child accesses the "accepted child keys" from the parent during the checking/the framework does it automatically
    - or the parent passes the accepted style properties to the child when it is mounted/some other time
    - this would allow for per-child defined accepted properties --> more flexibility
  - so where do the style keys come from? one could create enums, for each Widget, which define the properties which the Widget itself will use, these enums might conform to protocols to match the available properties with some defaults(need to check whether this is possible), so the work of supporting some standard properties is off-loaded to Widget autors
  - and then all enum cases could be passed in as arrays of strings, all property keys which are in this string array are accepted
  - here is a possible way to enforce support for certain properties on a framework level: by providing an array of strings that represent supported property keys like "foreground", "effect: blur()" or something like that which might not depend on a special Widget nor on the parent, although it would be possible to implement filters with a wrapping Filter Widget, but the foreground property will probably be applicable to any Widget and trickle down to children
  - if the Widget authors does forget to add any global supported property to the enum with supported properties, these properties will not be available in autocomplete, but maybe these properties can be enforced with a protocol
  - plugins to the framework, everyhthing that uses the framework could add supported properties through an initialization hook, which adds Strings to the supported properties array 
  - when doing it this way it would also be possible to add global properties to all Widget property enums with static extensions on the StyleKey or so protocol, because the global keys are anyway added to the array manually, they do not need to appear as enum cases
  - the array of the Widgets properties is merged with the array of accepted properties which the parent provides
  - and how are the types checked?
  - types can be checked by having a dictionary of type checks, keyed by style keys, even better, a dictionary of value assertions can be created, or both, one to check whether the basic type is ok (because for any property, any type conforming StyleValue is accepted) and then some assertion tests to check whether the given values make sense, and generate necessary evalution output, like error messages
  - the TypeCheck could be an enum value providing options like direct (compare ObjectIdentifier of the type with the given type), function (provide an arbitrary function that checks the given type), maybe even an error message for a type check failure should be provided with each TypeCheck, so make TypeCheck a struct with the checks as enum cases and provide a pattern based approach for creating error messages (this would be very useful, for example, when parsing textual styling information, or at any time really, since there are no type constraints on the values even in code)
  - the value validators could be done in the same way, a validator is not necessary everywhere
  - also: there may be situation where a StyleValue has an initializer that throws, and if it is initialized from a text based style definition, this alone might create an error, the validators are focused on the individual properties for specific Widgets which have constraints on the value, which are not included in the types initializer
  - how should these things be provided?
  - probably by providing dictionaries of StyleKey: Validators on different levels of the framework
  - a global dictionary which can extended by plugins and which defines any properties that are accepted anywhere
  - a per Widget dictionary which defines the properties that are accepted by the Widget, if any keys conflict with the global dictionary, there has to either be a crash or things need to be overwritten, crashing is probably safer
  - the parent of each Widget provides a dictionary of properties as well, and in the definition of styles, the keys are then accessed via ParentWidget.Styles.styleKey1 or something similar, this makes it clear that some properties come from the parent and others come from the Widget itself
  - if the parent dictionary keys conflict with any key of the other dictionaries, throwing an error is probably the correct thing to do
  - this approach offloads a lot of responsibility for checking and validating on framework and user code, instead of on the type system, which can also bring flexibility, and some types of checks cannot be performed by the type system, such as ensuring that values are within a range etc., validators would be needed anyway
  - whoever authors a Widget that should be stylable in a non standard way needs to define the available properties, checks and provide intellisense support by having something like an enum with the available keys at a known location for each Widget, these things can probably be enforced with protocols
  - for Widgets that do not require specialized styling, but instead act as containers for other Widgets, it might be good to forward the style properties of the first child by using generics or by wrapping the children in one default container and the wrapping Widget then always exposes these properties of the default container, the Widgets inside can be styled 

## Compare the advantages, disadvantages of the two approaches again

There are a few areas in which they can be compared:
1. user-friendliness (how convenient are styles to declare, how good is hinting of available properties, how good is type checking, how easy are the styles to access wherever they are needed)
2. creating, how difficult is it to create new style properties, types
3. extensibility, how well can the default framework properties be modified by outside
4. parsing, how can parsing of text be implemented, how good is key and value checking when parsing

<br>

1.

struct-property-approach:
- need to instantiate a different struct for each Widget
- probably would need multiple structs per Widget in certain cases
- if properties need to be applied to serveral Widgets which share them, a shared default struct needs to be used
- using $0. syntax for accessing properties, simple, but not very informative, repetitive
- it is clear which properties are available when the correct struct was found
- it is clear which types of values are accepted
- validation of the values can happen immediately after the value on the style was set (could use computed property set function)
- access of styles is very easy once the structs are instantiated by simply writing styleStruct.property

string-key-approach:
- the values can be accessed by accessing the dictionary of key: value pairs that were assigned to the Widget based on the selectors of styles
- the values need to be cast to whatever is needed, this should work, because the values havev been already tested to conform to the requirements earlier

2.

struct-property-approach:
- create new styles by defining a new struct, add StyleProperties to it, as well as the default style properties which could be enforced by certain protocols but would have to be added manually to each new struct
- or use multiple structs and the Widget specific structs really only contain the Widget specific stuff, when layout styles are added, would use a different struct to specify the layout styles on the Widget

string-key-approach:

- create by defining the keys as something like an enum and the checks and validators and available keys as a Key: Checks dictionary on a new Widget

3.

struct-property-approach:

- extend default styles by extending protocols and adding properties as computed properties

string-key-approach:

- extend the global dictionary of available properties and add the property keys to some global protocol to enable intellisense

4.

struct-property-approach:

- would need to define the structs which contain the properties in plain text as well, if not all properties are added to the Widget struct
- parsing would need to happen with type lookup for the structs, so the types in the plain text would need to use the correct struct type names with library prefix (probably)
- creating style sheets that look like css would probably be difficult
- it would be necessary to take all the properties in the stylesheet, parse them as key value pairs, then follow the selector and then let the Widget handle how these key-value pairs are translated into the right structs and then let every struct pick the values from the key value pairs of which the keys appear in the struct or a similar approach

string-key-approach:

- parsing can happen by parsing everything as key value pairs and passing everything to the Widget that matches the selector
- the Widget has all the info about which property keys are accepted and how to check their types and values
- the checking can probably be automated in big parts by the framework

## Can the two approaches be combined? Would it have any advantages?

- it might be possible to create structs inside the Widgets which provide simple access to the properties by defining getters into a shared property storage
- would that have an advantage?
- it would be an optional thing only used by developers for convenient access without having to parse the properties everywhere they are used
- it could also be used to provide defaults
- it probably should be left to the Widget author to decide whether to use such an approach or not, because the properties will mainly be used inside the Widget
- do the properties also need to be accessed outside of the Widget?
  - layouts need to access the properties of children, but this can be solved by taking all the childs properties and passing them to a struct which the layout Wiget governs, this struct then only takes out / provides access to the properties needed for the layouting
  - for some hacky stuff it might be handy to be able to access the styles of a Widget in a convenient way already parsed to the correct type and maybe with defaults
  - using a protocol and getter based approach this can be realised, every Widget could define a struct which conforms to a global protocol (which can be extended by plugins) which exposes the properties, for Widgets that do not provide any special properties, a default struct implementation would probably be possible
  - other Widgets might define their own
  - figure out how to solve this, however accessing by key value and then parsing is still possible without this, even from the outside, just not as convenient, but usually not a problem because the type of a property will usually not change later, a property which is a color will probably stay a color type, so it is not necessary to have the type checking system involved, as there are not many opportunities for wrong types to appear (if some wrong types are there the app will probably crash)

## Is an intricate styling system like this even necessary?

- alternatives would be to allow styling only by setting properties on Widgets directly, but this would probably lead to many users writing their own style distribution systems
- having a style system enables more customization, faster changes, makes applications look better, that way it should also be easier to mimick specific platform styles by applying themes
- it's awesome how web pages can be styled with css, and even desktop apps when using electron, see VSCode, the theming ability is a really handy feature

## Things to consider when developing a syntax

- the styles need to be checked in such a way that when an error occurs, it needs to be clear to the user which style threw that error --> the styles should be checked right after the instance is created --> crash immediately, another approach would be to provide a debugger for the framework, a view of the Widget tree where all the styles can be inspected and errors are shown there, the user can then figure out where that Widget and the corresponding styles were defined in the code, so tracking the origin of a style in the tree is necessary

## How to distribute styles within composed Widgets?

- a composed Widget like a button may contain a Container as a Child, a Row to layout it's children, a Text and Icon as children
  - which properties does the button expose?
  - it would be reasonable to let it expose a background property, a foreground property, a padding, filters like blur would be possible but can also be implemented with wrappers
  - the insides of the button should also be available for styling
  - for example, setting the margin between the two children should be possible from the outside, since the button is a core Widget and any application developer will want to style the button
  - the flex layout should be accessible as well, on the other hand, maybe the flex layout should not be included in the button in the first place, because application developers might want to distribute the children differently
  - so maybe the Button Widget should extend the Container Widget and provide mouse click functionality and state handling!
  - the state handling would be a difference here between button and container, but this difference would probably only show inside the selector, yet the button would have to overwrite the current active pseudo class of the container
  - maybe instead of going into overwriting, keep the composition approach and forward properties to the container
  - the properties of container could be manually defined on button or the enums could be typealiased and the dictionary with key: validators could be copied / provided as a computed property
  - the properties could then be passed to the container Widget directly, and even define the styles as reactive and update them whenever the styles on the button change
  - the style properties are passed to the container Widget directly
  - it could be useful to take the Container Widget out of the Widgets that can be styled from the outside, hide that Widget from the selectors, maybe with a flag that can be set on the Widget which forces the style distribution logic to skip that Widget
  - copying the properties of Container onto Button might be tedious and if a Container property changes in the future, that property will be missing from the Button properties (in the key enum), so it would be better to create a protocol for the Container Widget which defines all the property keys and then let the button key provider conform to that protocol, the protocol extension then always provide the latest version of the properties of the Container Widget
- a Widget like a ScrollView, which is a core Widget provided by the framework, has a child and enhances that child with the rendered output of scroll bars, these scroll bars are probably not Widgets, since many very small Widgets would be needed and the performance might decrease, so direct rendered output is used, selecting the scroll bars by classes is therefore, in the current setup, not possible, this is a case where pseudo elements should be used
- a completely custom implemented Widget which acts as a semantic wrapper for a certain tree of Widgets might also need to be styled, for example, a SettingsPage Widget, might receive a set of settings during instantiation and displays a ui accordings to these settings, whatever is necessary to modify them
  - this page can define an internal structure of classes, like wrapping each setting in a container Widget with the class .setting, which allows adding padding, background etc. from the inside of the Widget (there might be a default style) as well as from the outside if the class structure is known as well as the underlying types of the Widgets which have these classes
  - there might also be a layout Widget like Column, which should be stylable, e.g. for defining the space between the settings
  - the settings page itself may or may not expose any properties by itself, it could make sense to allow container styling properties
  - but this may not be necessary as a Container Widget can be added from the outside
  - well, but this would mean that a background cannot be added to all SettingsPages through some theme, because this would depend on the SettingsPage Widget being wrapped inside a Container
  - however the SettingsPage might have a Container as the first child, and then either the same thing as for Button can be done, or Container can be inherited directly or the Container Widget gets a class like .inner-container or so and background, padding can be added that way
  - the SettingsPage might get a class assigned by the code that instantiates it, and it can appear in the selectors, but the probably only really global properties like foreground or the properties that are relevant for the parent can be added to it (if Container properties are not forwarded)

## Reactive styles

- reactive properties are useful for changing the style of the application after user actions or other events
- they may be used to provide feedback to the user
- or for example to let the user change the layout of something, maybe switch something from horizontal to vertical layout
- or have some size/percentage values be calculated through multiple stylesheets, for example when the user moves a tiling separator -> multiple tiles need to update their widths
- reactivity of styles is probably mainly needed when values need to change after an event
- simple things can be done by using classes
- complex style changing behavior which involves computing values out of other values and hacky stuff, and non-hacky stuff like passing the properties that a button shares with container to the child container after a state change, would need reactive styles
- how can they actually be implemented?
- first of all: what can trigger a style update?
  - any event => maybe have something like: every EventHandlerManager exposes a handler which is invoked without data, like onFired or something
  - some ReactiveProperty changes, going with the former point, that would be the onChange event on a ReactiveProperty
  - maybe a reactive property is used in the calculation of the style
  - then it would be possible to use the DependencyRecorder to find out which these are and also provide a way to specify the dependencies manually
  - provide a function to invoke a style update manually from the outside, e.g. the defining widget could access the style instance and invoke an update
- implementation specifics:
  - it might be that only one property in one block is calculated and only that block needs to be reactive
  - for every reactivity the smallest possible recalculation should be done, so every block of style (that which is under a selector) should be individually reactive and only the properties
  - the sub styles should not be recalculated every time some property in the parent block needs to update
  - sub styles should get their own reactivity
  - of course they get their own reactivity as a block
  - but the whole sub style definition can be reactive as well
  - it should be possible to make a single property reactive and make the ReactiveProperty protocol conform to the StyleValue protocol whenever the value of the proeprty conforms to the StyleValue protocol
  - how to provide the triggers for updating?
  - can probably heavily use result builders to allow throwing in the triggers into each block
  - maybe the triggers should be added to the constructor
  - and should only count for the properties of a style -> only the properties of a style are reevaluated when one trigger is triggered
  - however the way to define a style usually includes a function builder, meaning that the properties of a style and it's sub blocks will be output by the same function
  - an if statement might conditionally add properties and blocks
  - maybe, reactive properties and blocks can be separated by the functions of the style builder? so that only properties can be made reactive
  - on the other hand it could be useful to be able to add blocks on demand/only if a condition is fulfilled
  - styles are probably added into the Widget tree by just specifying them alongside the Widget instantiations, but most Widgets do not feature reactive children as of now, instead, special Widgets which listen to manully specified triggers can be used to update a tree on an event
  - so the style instances that are created right in the tree will in most cases not be conditionally output
  - if reactivity is needed in those, the whole content of the style should be output conditionally, the style is an own reactive system, regardless of whether the root style object is output in a reactive of one-time static context
  - can reactivity be implemented later?
    - property reactiveness can be implemented additionally by either providing a flag or triggers during the definition of a property value as a closure/computation, the reactivity handling could then be done inside the property value store
    - the option to specify triggers for updates would need to be added, which should be an additional change, if triggers are specified, that would mean the style is reactive
    - if the applied styles of a Widget change, the property value store needs to be rebuilt
    - these changes should be additional

## Should styles be able to access their own and parent properties?

- this could be possible, since the styles are applied in a top down approach all parents should be guaranteed to be available and fully calculated whenever a new style is added to a Widget
- accessing the values would probably be done on a per property basis, using closures
- there could be a context variable passed in to those closures
- this context variable may give access to the already resolved peer property values, the resolved property value dictionary of the parent and maybe even access to properties higher in the tree
- the resolving of the properties could then automatically be made reactive, since the property depends on some resolved properties which can change, e.g. when some pseudo class of a parent changes and the property references the resolved parent properties
- dependencies might be tracked automatically, by providing a mechanism to record accesses to the resolved properties, maybe through a custom ResolvedProperties type with a subscript syntax that can record accesses
- a way of disabling reactivity and a way for specifying manual recalculation triggers should be implemented as well and maybe even prior to the automatic tracking
- maybe the default should be non-reactivity?
- resolving the properties needs to be done in a way that puts the properties with dependencies on other properties at the end (at least for properties that depend on siblings, the parent properties should all be resolved when the children are starting to be resolved), the properties may then simply be resolved, starting with any one, and if the property accesses a sibling which has not yet been resolved, that one should be resolved immediately, if the resolving of the sibling accesses the initial property currently in resolving, an error should be thrown
- this might be implemented using a custom type which has dictionary access and a resolve all function, and could be the same type passed to the context for the dependent properties, the type might receive all the given properties, from all styles, then merge them, check with the available properties and validate the values, then provide access to the values via a subscript, if a value has not yet been accessed, but the key is available/there are property instances with that key, calculate it (or just read it in case of a static property) and store the value for future access
- or maybe that logic should be put into the Widget class directly? each Widget could have a simple dictionary with all property values, well, then the access can't be realized in an on demand calculation/potential recording way
- so there should probably be some kind of StyleStore (or other name) for each Widget, which receives the widget instance and does all the style work, so that in the Widget itself, the style values can be easily accessed via a subscript with the appropriate style keys on that type

## Whether and how to handle inheritance of properties?

- is it necessary to have property inheritance?
- css has the inherit value for properties, which will fetch the property value from the styles of the parent element (not the parent style!)
- which properties could benefit from something like that?
  - in css this is probably mainly used for color which is named foreground in this framework
  - this property controls the color of text, icons, anything else which can be defined as foreground
  - so there are some Widgets which do not use this property themselves, but it might be used by some of it's children
  - there might be other properties, which Widget authors might want inherit which are not there by default and need to somehow be registered with the framework
  - or maybe instead of doing this with concrete properties, maybe enable defining the property value as a computation with access to parents, one could then access any property of parents and would not have to rely on name equality
- without a function like that: the color of text would have to be set with a selector matching Text objects, however there may be different Widgets which are Text and Widgets which are not part of the core library of Widgets which can be used in places where a Text can be used as well (e.g. inside a Button), so having a property which is inherited by all these, even new Widgets would be practical for writing styles, because the author of the styles might not know in advance which exact Widgets will be used somewhere
- this applies to properties such as fontFamily, fontSize etc. as well
- another option would be to use something like generic types/protocols in selectors as well, check whether a type conform to a certain protocol, well this is probably not that easy when doing it all with pure swift types, the conforming protocols would probably need to be declared as variables inside each Widget instance
- maybe pseudo classes could be used and the Widgets which all can receive text relevant properties could be selected like "*:textual" or similar
- however this does somehow still make the assumption that all of these properties are consumed by some Widgets, there may however be Widgets which only use parts of these properties and mix them with other properties
- additionally one would have to remember which different generic types are there and which properties they support
- simply specifying the properties like normal ones would make things easier and look more familiar since this is how it is done in css as well
- how should it be implemented?
  - first of all: which properties can be inherited?
    - probably only those which are for sure applicable to every parent Widget
    - there should probably be defaults for all of these properties on the root level
  - how to register such properties?
    - register them globally on a framework variable / with a framework function or via the WidgetContext
    - either can put defaults there
    - or maybe global defaults can be omitted and providing default values is the task for each Widget authro
    - this might however lead to a non unified default appearance
    - so, add the option to provide defaults with the definition of a property
      - since properties could still be nil, each Widget author should probably still provide custom defaults for each property, just in case there is no value given by the parent, but in normal cases the global default will always be available and automatically passed down
    - maybe only certain properties should be defined as inheritable
  - when using a pure name based approach:
    - the properties should probably be fetched directly from the parent
    - this means that not the whole tree branch will be traversed up until a value for the property is found, which should help to increase performance
    - to ensure that the properties which are defined as inheritable are available on the parent directly even when the parent's own property value is inherit, the property values need to always be passed down to children with an actual property value, they should however probably not be merged into the applied properties unless the property with the value inherit has been explicitly specified on the Widget
    - or maybe they should be applied?
    - maybe there should be a differentiation made between the applied properties (that have been declared and merged through style definitions) and all property values available on a Widget
    - this might be useful to preserve properties with a value of inherit in the applied properties variable, while also making it easy to access the real value, which would be the value of the parent, through another dictionary
    - this dictionary might get all globally inheritable properties of it's parent merged in by default and then after evaluating the properties defined by the applied styles, potentially overwrite some properties which were fetched from the parent, this mix of properties still equal to the parents properties and properties defined by the Widgets's styles are then passed to the Widget's children which in turn, first inherit all values and later may overwrite some of them with their own
    - again: should there be a distinction between properties that are inheritable and not inheritable? probably all properties can be inheritable, but when assuming that the inherited value is taken from the "computed/resolved property values dictionary", for most properties inheriting over many levels will not be possible, instead an inherited value will only be present if the direct parent defines a property with the same name and also has a value for it
    - for the global properties: should they all be passed to every widget in every case?
      - they can be defined on every Widget
      - every Widget can receive a value
      - the default for global properties might be to inherit the parent's value
      - other defaults may be possible as well
      - since it is assumed that the property can be defined on every Widget, it can also be assumed that the property should be accessible in every Widget
      - so if the values would not be applied by default, it would be necessary to redefine the global property on the specific Widget, which kinda goes against the point probably
      - again about the defaults: if the default is inherit, every Widget will have a value of inherit, but there will be no value to inherit, so either for each global property there can be an additional value specified, under a name like rootValue, which is optional, but will provide the base value for inheritance
  - when using a manual access based approach?
    -it would be more like a computed property with access to a context which gives access to the parents resolved property values and other values, so this might be a thing to have on top of the inherit approach
    - the property values which are computed that way can in turn be inherited by children
    - it is practical to be able to simple specify inherit without needing to write a closure for each property
  - when the closure approach is there as well, values might be fetched from farther away parents, there may be utility functions and a convenient api to do this, e.g. to fetch a property of any parent of type T etc.

## Animations, transitions or something else?

## How to handle scoping/non-scoping, hiding the internal structure of a Widget/making it stylable only with a special selector syntax, is this even necessary?

## Handling pseudo-elements
- pseudo elements would be used for visual output that is not directly describes as a Widget by itself but instead generated by a Widget as a part of it's appearance, e.g. the scrollbars in a scroll view are not separate Widgets (probably) and therefore cannot be selected and styled with normal type, class, etc. selector syntax
- therefore a special syntax and approperty holder might be required for styling such parts
  - the style selector could be, as in css: SomeWidgetType1.someWidgetClass1:someWidgetPseudoClass1::somePseudoElement1
  - easy to understand because syntax is known from css
  - makes it clear that some structures are not separate Widgets
  - separates the Widgets properties from these visually distinct structures
  - however: the identifier of the pseudo element needs to be known in order to be able to change the properties, however each Widget could define an enum with pseudo elements, the availability and checking could be done similar like with properties, but would there be pseudo elements that are globally available? question discussed below
  - the properties available on the pseudo element would need to be defined somehow, and the properties need to be accessed from the Widget containing the pseudo elements in order to be applied to the rendered output
- another way would be to add something like pseudo children to a Widget
  - these could be selected like usual Widgets with a class or type selector
  - and properties could be defined on them and applied to them
  - this would make it unnecessary to implement new specialized logic to handle non-Wiget-parts
  - but it would hide the fact that some structures are not Widgets and can't be addressed like Widgets directly
  - and some kind of logic would be needed to react to changes of the style of the dummy Widget in order to update the renderings of the parent
- another way would be to use special properties on Widgets that have such parts
  - so the styling would happen on the Widget which has those part directly and there would be no indication of a hirarchy
  - the special properties would probably get a prefix
  - what would be the benefits?
    - no special system/functionality needs to be implemented
    - one would not need to know/remember how to access the style of the non-Widget-part, since the properties are available through the keys enum on the containing Widget
  - what would be disadvantages?
    - the non-Widget-parts would not have a distinct identification in the style tree although their are visually perceived as distinct elements
    - the parts could not be styled in a cascading way, the widgets which have this part available would need to be selected specifically, for example: when there is another Widget which also uses scrollbars which are custom implemented or use a shared rendering routine with other Widgets that use scrollbars, each of these Widgets type names would need to be known in order to change the appearances of their scrollbars, and if a library implements a new Widget with scrollbars, themes which change the appearance of scrollbars won't affect this Widget's scrollbars, if the theme is not designed to work with the library
    - other ways would be to add classes like: has-scrollbars or something like that and apply the styles on that, but it seems like classes should better be used in the structure and style of an application and not such much in core element properties
  - maybe pseudo-classes could be used to indicate a Widget has scrollbars
- the approach taken will probably be the one with the :: syntax
  - **would there be pseudo elements that are available on every Widget?**
  - **should pseudo elements receive and support globally defined Widget properties?**
  - how to implement defining which styles are available on pseudo elements and how to access them from the Widget?
    - there could be sub structures on the Widget with pseudo elements which conform to a certain protocol which enforces the availability of style definitions
    - when styles for a pseudo element are defined, that struct could be instantiated and the properties could be set on it, the instance could be added to a dictionary on the Widget which is keyed by the pseudo element names
    - the available properties might as well be directly defined on each Widget inside a dictionary keyed by the names of pseudo elements
    - **more implementation details necessary**
  - can this be added to the system add a later point without breaking all other parts?
    - syntax in selector can simply be added
    - Style and StyleProperties constructors and builder functions can be adjusted to take more general type inputs, anythink that has StyleKeys or something like that, in order to allow for convenient definition of the pseudo elements properties
    - the styles are normal styles, only the selector has added syntax
    - the algorithm to apply the styles would need to be updated to check whether a selector selects a Widget and then check whether the selector selects a pseudo element inside that Widget, or just let the select match logic check on a Widget and it's pseudo elements from the start and only return true if the pseudo element matches as well, the applying process of the styles (maybe inside the Widget itself) could then handle the distribution of pseudo element properties to the property holders for the pseudo elements
    - so probably mostly additive changes would need to be done on the style distribution logic

## Handling media queries (are they even needed?)

## Handling layout relevant properties like margin, flex-grow etc.

## Theming and updating styles when theme variables change (during runtime)

## Handling styles that change the size and layout of Widgets

<br>

## Needs Clarification:

- are styles reactive? and if so at what level? at each property? or for each Style element, and where do the dependencies for the reactive calculation come from? from the Widget --> properties?

- how to handle overwriting? which values are preferred?
  - do styles that are defined closer to the widget always overwrite farther away ones?
  - or can a farther away one with e.g. more classes matched overwrite the closer one?

- how to handle nesting? 
  - should every style object contain it's children directly?
  - should only specific types of style objects be allowed to have children? --> e.g. via conformance to a protocol?

- how powerful are the styles?
  - can they hide Widgets?
  - can they move Widgets around?
  - can they change content such as text?
  - can they create new Widgets?
  - can they apply e.g. a background color to every Widget regardless of whether
  it has a child Background Widget or not?
  - can a Style definition accesss it's parents / siblings (matching Styles)

- how to approach common values?
  - such as foregroundColor, backgroundColor, opacity, debugLayout, ....
  - should each style match a WidgetStyle protocol?
  - and if only unspecific (shared) properties need to be set on a variety of
  Widgets of a different type there should be a AnyWidgetStyle struct which implements WidgetStyle?

- what to do if a wrong specific Widget style is applied to a Widget?
  - crash?
  - isolate the properties that are shared, by protocols such as WidgetStyle and use them anyway?

- how are pseudo classes managed?
  - a button for example may have :hover, :active and :disabled
  - there might be other Widgets and custom Button Widgets made by library users which
  have the same pseudo classes
  - there might be Widgets that don't share any pseudo classes with other Widgets
  - pseudo classes are probably mostly used for state management, like for the button or maybe a :loading pseudo-class for a Widget that loads something, e.g. an Image, could then use this Information for some convenient styling