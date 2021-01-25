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

- how could values that change over time be included in styles?
  - could use the same syntax like css
  - transitions:
    - transitions would be used to provide a simple way to morph a single properties value to add some reactivity to an application, e.g. after an event, like hovering a button -> change the background color
    - specify by property name, how the value changes over time (duration, easing)
    - if a value in the resolved properties of a Widget changes and the current transition property includes a transition definition for that property, a transition from the previous value to the new value might be automatically started
    - the values could be changed right on the resolved properties storage
    - however the values need to get into the render objects somehow
    - the Widget might have a handler on the properties storage which fires if a value is updated and then the render objects could be updated
    - another way to handle it would be to let the property storage always provide the current value as defined by the transition, by not storing the value once computed, but always recalculating it when it is accessed
    - the render object might then receive some notification about the ongoing transition, during instantiation of the render object, the property on the render object might be defined as an autoclosure and update on every frame, accessing the the value in the property value storage will will recalculate that value on demand
    - how to notify the render object of the transition? there might be a sub dictionary in the property values store which outputs transition information for a specific property or nil, if no transition is running
    - this information could then be used in the render function of a widget to construct RenderValues from this information, maybe the transition can even be passed to the RenderObject directly?, but the RenderValue approach should be usable as well, RenderValues can be fixed and timed, so the RenderValue to make should be decided in a switch statement and then simply passed to the RenderObject
    - and since the easing and calculation is all handled by the style system, these things can be removed from the RenderValue, simplifying it, it only needs to access the current property value on every frame and also know when the value won't change anymore to stop requesting a new value at some point to improve the performance of the application
    - there might be default strategies to calculate intermediate values for the standard types such as double and Color
    - other strategies might be added to the property definitions on a per property basis or on a per property value basis, maybe every StyleValue should have a default function to calculate intermediate values, if the style value conforms to TransitionableStyleValue or something, which would also signal to the property that it is transitionable by default, but the property may overwrite the default behavior and be defined as non transitionable, or with a custom intermediate calculation function
  - animations:
    - an animation would be used where precise control over the value at a point in time (relative to the duration of the animation) is needed
    - and if multiple values need to be changed together
    - like in css, the value at certain points in time might be controlled by providing concrete values on specific key frames (maybed keyed by percentage value of time passed), and the intermediate value calculation function of each property would be used to connect the key frames
    - a dedicated structure is necessary to define animations
    - it might be called Keyframes
    - a Keyframe struct may in turn accept the same property: value definitions as a pure style block, but it also has a timing property
    - there can be multiple keyframes with the same timing in an animation, the properties will then be merged in the order the Keyframes are added
    - the Keyframes object should then be passed as a property value to a property called animations, an optional easing, a duration, a delay and a repetition are specified as well
    - maybe there should be a whole Animation struct containing the keyframes and the just mentioned properties
    - multiple animations can be passed to the animations property
    - how are the animations executed?
    - the start time of an animation should probably be the time of merging the property into the resolved styles or the first read access or something like that/maybe the first access in the render function or any first access after the merging
    - the style property value storage should probably go through all animations, and find out which properties are being animated, and separate out one internal animation definition for each animated property, collecting the values at different points in time and all other relevant properties for an animation
    - if a value is changed through multiple animations, the last animation defining that value should be the animation taken for that value
    - maybe the property values for the keyframes should be limited to non-reactive properties, to avoid even more complex resolution of properties, at the start
    - this function can however be added in a non-breaking way for the user, only some things in the backend need to be adjusted, the property storage which would go through the animations property to generate the per property animation definition should already have access to the whole context and also to all other properties, because the resolving of properties is probably done before the animation property is evaluated
    - so actually it should be possible to provide computed keyframe values with a context
    - should the property values also be made reactive?
    - there could be very fun interactions between transition and animation if this would be possible
    - each single property animation definition would need to update itself if any of the property values extracted from the keyframes changes
    - when the animation is running, the current output value could abruptly change, or the previous animation path can be merged with the new animation path by the transition definition (so the merging of the two animation paths would happen over the duration time specified for the transition)
    - that way it could be possible to even merge two animation paths with different durations and different key frames times
    - so the keyframes could be made reactive as well
    - a key frames definition could receive a context as well and based on this compute the keyframes
    - every animation definition used in the animation property probably has one keyframes definition, but it might even be possible to pass in multiple and merge them all together
    - the keyframes definition would have to be resolved after all properties when the individual property animation paths are to be determined
    - if a reactive keyframes definition is updated, a new animation path would have to be determind for the properties which contain values from that keyframes definition
    - so this can get kind of complex, probably limit keyframes to non-reactive conrete values
    - can the keyframes definition be reused? 
      - by simply storing the instance (it should be a struct) somewhere manually, this should be possible
    - the animation definition might then also be exposed to be used in the Widget's render function to generate render values
    - however there may as well be a simpler output for the render function which only defines that the property's value is changing, when it starts changing and when it stops changing in order to perform more efficient rendering updates
    - if a transition would be running at the same time as an animation, the animation should probably overwrite transition values, since it is more function heavy
    - if an animation would start after a transition has ended, this should simply work, the transition first transitions to the fixed value given for the property key and then the animation takes over with it's keyframes values
    - when a transition and an animation are present and the animation has a delay at the start, the timing information output to the render function needs to unify both of these timed update definitions -> find the real start and end points by looking at both
  - **should a single path be calculated for each property over time out of the transition and animation properties, which could then as well be exposed to the render function?**
  - can animations and transitions be started manually?
    - if the animations and transitions are somehow exposed by the property store, or maybe even a unified update path for every property, it might be possible to call some function on these exposed objects to rerun the whole thing
    - another way would be to use classes or pseudo classes as triggers, after a transition/animation is over (there should be events emitted by the value storage for each property to indicate that a dynamic update process has started or ended), change some class or pseudo class, remove it and then add it again, this should restart transitions, animations, this is however an inefficient approach as it triggers a reevaluation of styles and properties just to rerun the same timed updates
    - if the updating of property values is handled by passing an object to the styles which is retained outside of the styles, this object might be used to restart updates
  - **are the values of transition and animation definitions inherited and overwritten by child definitions, or are child definitions appended to the parents definitions, can this be made configurable on a per property basis, how?**
  - should transition and animation properties be overwritten if they occur multiple times in a block or should they be appended --> maybe define a merge strategy for certain properties?
    - it could be useful to be able to merge these properties instead of overwriting them, to be able to add a transition reactively, maybe wrap it in an if statement
    - or maybe merge transitions from different style blocks, a block might get applied after a class has been added to the Widget dynamically, extending the list of transitions
    - this might lead to transitions for the same property being defined multiple times, in that case, the last transition defined for a specific property key should probably be taken
    - the merging should probably only happen to the properties that are declared to match the Widget directly, parents properties should not automatically be merged in at all times, since the transitions depend on the properties available on every Widget
    - but transitions could be pulled in from the parent
    - but could transitions be overwritten at all? it would be useful to overwrite them, e.g. to change the duration of a certain transition for a specific property key between hover and active pseudo class
    - this overwriting would be possible when the later transition for a specific key overwrites the former, so the styles for active need to be as specific as the styles for hover and be declared later, then they will overwrite
    - but can transitions be disabled?, it could be done by allowing to pass in a no-transition value with a property key, maybe the transition value should be a list of enum values (.none(key), .some(key, duration, easing)) or maybe not to be able to provide convenient default values, maybe a struct like Transition(key:) should be used, with some static function like Transition.none(key:) which outputs a no-transition value
    - what about animations?
    - animations are resolved on a per property basis --> an animation path is generated, and probably the last animation defining values for a certain property defines that animation path
    - so overwriting should behave just like it does for transitions
    - if a value is overwritten, it will probably trigger a replay of the animation/all animations defined would probably restart, since it is kind of complex to check which animation path really changed and which didn't
  - **how are such changing values inherited? --> e.g. color transition on a parent, how is the value efficiently passed to the children**
  - could there be other approaches? maybe not two separate timing types but a unified one?
    - everywhere where a property value is accepted, a definition of a timed updating value could be accepted as well, there could be a type such as UpdatingPropertyValue which can output a value based on some timestamp
      - the type checking would need to be done by accessing the first value output or maybe even on every output, although that will probably not be an option because of performance penalties
      - the property storage would then notice that instead of a fixed value, an update definition was provided and setup the necessary callbacks and whatever to always refer to the update definition (as long as it's not arrived at a fixed definition) when a property is accessed on it (the store) through it's key
      - such an update definition may also be stored somewhere, e.g. in the wrapping Widget and functions could then be called on it to restart it etc.
      - however with this approach it would not be simple to transition from a previous style value to a new style value, since the update definition is the property value itself, there might be an old value which is where the old definition was when the property value changed, but the new definition does not have a separate target value, because it occupies the place of the property value, the target value would need to be included in the definition
      - also, by passing one definition per property, controlling or defining multiple properties changing in the same way becomes more work, because either there needs to be a kind of wrapper which then outputs the individual property change definitions, or the same durations, timings etc. need to be repeated for all properties
      - and it is not similar to css
      - but could potentially provide a lot of flexibility
      - well there could be some default initializers for common tasks like transitioning from an old value of a certain type to a new value
      - and the wrapper for multiple properties at once would essentially be like a keyframes definition
      - but it seems like this would achieve the same things like the css approach without the familiarity
    - **there might be more approaches to consider**
- how could larger effects (big parts moving, fading, expanding, transitioning into one another etc.) be realized?
  - a fading transition, fading a big block of composed widgets can be achieved by wrapping the block into a functional Widget, which wraps the render output of the other Widgets in some kind of Opacity RenderObject, this Widget could expose an Opacity property, and then either transitions or animations could be used to change the opacity over time
  - a big move transition could as well be realized with a wrapper Widget which wraps everything in a translation RenderObject and exposes a translation (or maybe directly do everything with transform) property which can be updated through transition or animation, the target value would be calculated somewhere in the Widget and stored, maybe as a property of the Widget (composed Widget) and then added to the styles on some event, e.g. when a button is pressed the containers translation property changes (maybe a reactive style property value, or maybe update the whole style block) is set and a transition automatically moves it there
    - the translation property can be made reactive as a single property which could increase performance of the update/starting of the transition, because not the whole style block needs to be reevaluated
    - the animation could be used to provide a more fine grained path for the animation, instead of the linear transition interpolation, the animation property could be defined as reactive and an animation definition provided when the animation should start, the keyframes would have to be calculated on demand/before adding the animation to the property, using values available through the Widget instance
  - maybe opacity, translation etc. should be added to the Container Widget as well
  - how to do an effect where a Widget expands into another Widget, e.g. press a button, that Button expands to a new Page with content
    - one could create a special Widget which performs these kinds of transitions
    - this Widget could either contain the two Widgets which should transform into each other
    - but because their are probably not semantically/structurally linked in the application, this will probably not be possible
    - instead when the transition should happen, the larger parent Widget, a composed Widget containing the two Widgets to be transitioned as well as the transition effect Widget, should take the render output of the first Widget, maybe rasterize it into a pixel graphic/or ensure that it is a Container Widget, so that the background property can be accessed as well as the shape of the background
    - then it should take this initial shape and color and create a new path below the first Widget, then fade out the first Widget to hide it's content, then modify the path into the shape of the second Widget and then fade in the second Widget
    - the path update could be done completely manually, calculated in the Widget, without relying on styles and animations, transitions and the Widget could expose some special properties to control the effect
    - or when animation, transition should be used, on could use a path Widget to provide the intermediary visualization between the two Widgets and make the path segments a style property that is transitionable, animatable automatically
    - then either could the path segments be specified in multiple Keyframes and the exact shape of the blow up determind by calculations made by the Widget
    - or there are generic calculations to transition any path into another, using a transition
- **could this be implemented at a later point?, what preparations have to be made to keep this an option?**

## Should a special merging strategy be defined for certain properties, e.g. transition, animation?

## How to handle scoping/non-scoping, hiding the internal structure of a Widget/making it stylable only with a special selector syntax, is this even necessary?
- scoping might be useful to prevent styles from accidentally changing something inside a composed Widget which is not intended
- for example, the a style might be applied to a class based on it's selector, this class may conincidentally be used in a composed Widget as well, that Widget may even come from a Widget library, so an application of that style to the Widget would be an unforseen sideeffect and it will not immediately be clear to the user which style is causing it
- so it might be useful to hide Widgets in a subtree under some specific syntax, if the sub structure is to be styled
- this might apply to all composed Widgets
- the styles that are defined inside the composed Widget should only be able to style the Widgets that are instantiated within that composed Widget and not any children of those
  - are there exceptions to this rule? is there a situation where the sub structure should not be hidden?
    - yes, for example a simple structural Widget which is used to instantiate some Widgets to display some data or something, but the styling should happen where the Widget is used
  - any exception could probably be implemented by setting a flag on the Widget
- how could this be realized?
- somehow a distinction needs to be made between the Widgets that are visible to the composing Widget and those which are hidden
- maybe it could be done if Widgets were instantiated right away, and the sub Widget's instantiation would be delayed
- another way would be to either define a sub class of Widget, which indicates that this is a scoped container, or set a flag on a Widget instance to indicate that it is a scope container
- an identifier for the scope should also be given, the id of the Widget could be used, or a special identifier for the scope could be implemented
- when going through the tree to apply the styles, the last Widget which was a scoping container could be tracked, the styles would then immediately be appended an information about which scope they came from, whenever a style is to be checked to be applied to a Widget, it must then be checked that the Widget is in the same scope the style came from, if fetching styles and application happen in the same loop, it should be checked whether the current scope is different from the scope of the style checked for application and if yes, take that style out of the array of possible styles for application
- the root node of any scoped tree should still be stylable, only the children should not be accessible with normal selector syntax
- actually children that are instatiated in a composed Widget and are passed to a scoped child should probably be stylable from the scope of the composed Widget and not the scoped Widget that in the end contains it
- so maybe the instantiation and tracking approach is necessary
  - during the build function of each Widget, the instantiated Widgets might be checked, and the scope they came from recorded -> set scope information on this Widget
  - this should be possible without the children of these Widgets interfering, because when the parent builds, only the direct children are instantiated, children of the children are only instantiated when their own build function is called
  - currently most Widgets which take a child as an argument, will store the build function for that child and not instantiate it right away
  - this should probably change in order to be able to assign the correct scope to these children (which is the scope which defined these children and not the direct parent)
  - it would also not be a problem, since the build function is usually only used once during the initial build
  - but there might be Widgets where the build function is called again and at a later point in time
  - for example a Build Widget which rebuilds it's child with the help of a builder function after a property has changed
  - would it be enough to assign the containing scope of the Build Widget to these Widgets?
  - the question is: does the build function always come from the scope which contains the Build Widget?
    - the function might not be defined in that scope always
    - but from the definition of the Widget tree it will be obvious that every child the build function creates should belong to the scope that contains the Build Widget
  - actually the Build Widget should probably not be a scoping container, so there would not be a problem here
  - then what about for example a List Widget
    - a List Widget receives the data items it should display and a build function to build the child for a specific data item
    - but the direct children of the List can be build right away in the constructor
    - on the other hand, if the List has the ability to dynamically update it's children when the data property changes, the build function might be invoked at a later point in time
    - but the List Widget should probably not define a scope by itself, because it is only a functional Widget
    - so anyway the new children will get the scope assigned which the List Widget is in
    - but assume that the List Widget does something more than just instantiate the children and defines it own scope to hide some extra Widget it instantiates from the scope using it
    - then the List Widget can still simply apply the scope containing the List Widget to the newly instantiated children, because it will be clear, that the children originate from the containing scope
  - or is it so?
  - what if there is a composed Widget which contains a Widget defining a new scope which takes a child and the child also defines a new scope and takes a child?
    - will the last child correctly be assigned the scope of the composed Widget?
    - the first scoping Widget will be instantiated within the build function of the composed Widget, so itself will be scoped to the composed Widget, and the child passed in will also be, since it is instantiated right away
    - the other children which the first scoped Widget may define will be instantiated later and be scoped to the scoped Widget
    - the second scoped Widget is the child of the first and is already instantiated with the first one and will by that get the scope of the composed Widget, as well as it's child which is instantiated right away as well
    - so in this case the last child would receive the correct scope
    - what if the second scoped Widget would rebuild the child (it saved the build function)?
      - since the second scoped Widget is scoped to the composed Widget, it will assign this scope to the newly build child (if it is implemented correctly)
  - maybe it would be possible to let the Widget builders handle the scoping
    - right now, a Widget builder returns a build function
    - it does not hold parameters/attributes
    - but if the Widget builder instead returned an object, this object could hold information about where that builder was instantiated (in which scope)
    - if some Widget then uses this builder at a later point in time, the builder will assign the correct scope to the Widgets it outputs
    - for this to work, a global variable would need to be defined which holds the current active scope, whenever a build is performed
    - the function builder would read this variable in it's buildResult function and assign the scope to the result
    - this might be useful for Widgets which define a scope on their own but take children
    - the Widget author would have to manually assign the containing scope to the children if they are rebuilt, which can cause bugs
    - by using a builder function which retains that information, bugs could be reduced
    - however it is questionable whether such a builder should be used for all Widgets which receive children, since most Widgets probably don't need to store their builder, since they could just call the builders of their children in the constructor and support correct scoping that way
- so the scope information should be handled by the Widget tree/Widget tree building logic, because this is where the belonging to a certain scope can be determind, and not by the style application logic, when the later runs, the scope information should already be fully available
- what syntax could be used to style scoped Widgets with a style defined in a different scope?
  - webpack uses the /deep/ syntax
  - since there can be multiple layers of scopes, the selector syntax should probably open up one scope at a time
  - e.g. by first selecting the Widget which makes the new scope, maybe with a regular class selector
  - after that some new syntax could follow
  - e.g. adding a "<" right after it: .scoped-widget-class-1<
  - this syntax could be changed at any time
  - adding a /deep/ after any scope opening part is also an option
  - for this approach it has to be known which Widgets define the scope and how to select them
  - another approach would be to disable scoping altogether on a per selector basis
  - this might be an additional feature
  - and could be realized by adding something in front of the selector
  - could be useful to e.g. uniformly style text in the whole application
  - so this is definitly necessary
  - and probably even more important than the per scope opening
  - maybe adding a /noscope/ in front of the selector would be a good syntax to disable scoping
  - and maybe a /scope/ after every scope opening selector part
- how does the style application logic have to look to support that?
  - when going through the Widget tree, keep track of the currently active scope
  - assign the source scope to any Style definition
  - when testing whether a selector matches a Widget:
    - if the selector starts with a /noscope/ (or equivalent meaning) process everything without considering scopes
    - otherwise
    - the selector can only be started to be checked if the Widget to be checked is in the same scope as the Style with that selector
    - maybe take selectors that start with & out from that rule, since those are meant to apply to the Widget containing them
    - when the scopes match, start matching the selector
    - match the current widget to the first part (aggregated)
    - then check each of the children (deep) for a match with the next part of the selector
    - it can only match if it is in the same scope as the style of that selector
    - or if it is not in the same scope, it must be in the scope that is created by the previous matched selector part (and the part opens up the scope)
    - repeat this
- again: how to enable scoping on a Widget?
  - probably simply set a flag on the Widget --> widget.scoped
  - to identify the scope, use the Widgets id
- can this be implemented later?
  - this should be added from the start to see whether the approaches can work and also because this can influence how new Widget's need to be designed to support correct scoping

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

## Media queries
- media queries should probably be added to the Style selector without providing a string parsing syntax in the code
- because this would make the non-swift language checked parts quite long sometimes
- what do media queries do?
- change styles based on properties of them medium being used
- there might be more useful queries, like testing for a property on the parent, or a parent size or something like that
- actually these things could be realized with a context passed into a style, some reactivity triggers and some if statements
- so it's questionable whether such a feature would be very useful in code
- it's more useful when writing text styles, since there is no parent to access
- a special syntax for declaring conditional styles might be needed for textual styles
- after parsing this would probably resolve to some conditionals using the context and reactivity
- should a media query feature be needed in code as well, can it be added later?
- yes, it would probably be non breaking for most of the code not using it, in the backend of resolving the styles it should mainly resolve to some additional checks whether the query is fulfilled before testing the selector

## Theming and updating styles when theme variables change (during runtime)

## Handling styles that change the size and layout of Widgets
- especially the style properties which originate from layout Widgets have an influence on the size and position of Widgets
- when these style properties change, e.g. because a class is changed and other styles match a Widget, a relayout or maybe more needs to happen
- look at the Flex layout Widget:
  - there might be a property flex-direction on the Flex Widget itself which can change the box config, layout and size of the Flex Widget and it's children
  - there might be a property cross-alignment on a child Widget, which can change the position (start, middle, end) and size (stretch) of the child Widget
  - so these properties need to be listened to and the correct lifecycle triggers emitted
  - for the Flex layout Widget:
    - this can probably be done if there are variables for the relevant flex properties on the Widget which might get a default value
    - and the values for these properties are also extracted from the resolved styles, a handler is attached to the event that is triggered when the resolved style properties change and overwrite the values of the class variables
    - the property values should conform to equatable, the class variables can the test for a change in the didSet handler and if the values did change, trigger a corresponding update, lifecycle function based on which property changed
    - for the children in the Flex layout, the update has to be done in the Flex Widget as well, since the layouting and everything is done by the Flex Widget
    - the box config of the children should stay unaffected
    - for the cross-alignment property, a relayout of the parent is necessary
    - an internal representation, one per child Widget should contain the relevant flex properties, define a default and overwrite them with values from the resolved style properties + add a change handler to the style properties
    - and then check in the didSet handler whether the value has actually changed and trigger the correct functions on the Flex layout parent
    -  the parent instance may be directly passed to these managing objects
- so this is something to be handled by every Widget itself, probably
- since the styles should by default change the appearance of a Widget, the default could be to invoke a rerendering of the Widget
- since the evaluation of life cycle hooks happens on a per tick basis, the default invcation of a rerendering should not interfere with calling any lifecycle method that needs to be executed earlier and will itself trigger a rerender, such as relayout
- there might be changes of the style which don't affect anything, like removing a class which caused some property values and adding a class which leads to the addition of the same exact property values
- for efficiency reasons it might be useful to force a compare function on StyleValue on an instance basis, to avoid having to use Self in the protocol
- the compare function should take any other StyleValue and check for equality, most values will first try to cast the StyleValue to their own specific type and then perform an equality check
- the compare function could then be used to compare the previous resolved style properties with the new ones and trigger a rerender only if something actually changed
- however it has to be taken into account that if a transition or animation is running and previously it wasn't, the rerender has to be done even if the starting value in the resolved property values dictionary equals the previous value, and also the other way around, since the presence of an animation can influence the way the render objects are defined
- maybe the correct life cycle hook to be triggered can be included in the property definitions, since it might be the case that some layout relevant property changes, but the layout and size does not actually changed, in such a case a rerender is unnecessary and the default rerender call would be inefficient
- having the call in the definitions is useful to avoid that for every Widget, every property needs to manually be tied to some lifecycle call by using handlers and if statements, this can cause lots of bugs because a property could easily be forgotten
- an enum value defining the lifecycle call to be made could be added to the property definitions
- it may be optional to allow disabling the default lifecycle invocation logic and letting the Widget author handle it manually
- should multiple different lifecycle invocations be allowed per property?
  - probably not, and if this should be the case, this is probably better handled manually
  - it is also a small thing to change, should it become necessary
- what about the global defintions, should they define a lifecycle call as well?
- there are properties such as foreground, which are candidates for a rerender of the Widgets on which this property changed
- not all Widgets might make active use of these properties though, because they may be passed down to children but not affect the parent directly
- if new global properties are added by a user, these properties cannot have any affect on the core Widgets, since those were not designed to use these properties
- but it might be possible to define these properties on them, because they are passed down to their children which may be affected by them
- a solution might be to define a lifecycle call on global properties as well, but to only use it when the Widget receiving the properties has defined that it actively uses a global property, a new variable might be added to Widget which defines the keys of the globally defined properties that are actively used by the Widget
- then how can the lifecycle calls of the global properties be overwritten or disabled and handled manually?
- just don't specify the key of the property in the variable indicating the automatic lifecycle management

<br>

## Forwarding styles, classes, etc., taking a Widget out of the style tree
- there might be functional Widgets, such as the Build Widget, which should not take part in the styling process and be transparent to all styles and classes, etc. applied
- therefore a way needs to be implemented to implement this transparentness on a per Widget Type or per Widget instance basis
- transparency might be useful in composed Widgets such as Container as well, because the relevant properties of it's children Background, Padding, etc. are exposed on the container directly
- allowing a style definition to access these Widgets from the outside would not be useful
- but these Widgets might not always need to be transparent
- so it is probably best to implement transparency on a per Widget instance basis
- by adding a flag to the Widget class
- what should be the behavior of a transparent Widget?
  - it should not be able to be selected by any style selectors
  - and therefore it should not receive any styles from the style distribution logic
  - directly applied style properties are valid though
  - it should not even be selectable as a part of a selector
  - it should be completely jumped
  - what if the Widget that is transparent defines a scope? --> how to open that scope if it can't be selected in a selector?
  - answer: a Widget cannot be transparent and create a scope at the same time, if a Widget is configured that way, throw an error
- for the forwarding of classes, properties:
  - this should probably be done by the Widget which wants to forward something to another Widget
  - the amount of forwarding to be done might be different
  - the Container Widget will not forward it's classes
  - but the Build Widget will (probably)
  - it could also not accept any classes at all
  - making it transparent to style selector might be sufficient
  - what about resolving properties with a value of inherit?
    - when a Widget wants to resolve a property with a value of inherit, it will do this through a context which provides the parents resolved properties
    - when the parent of a Widget is a transparent Widget, this context should instead point to the next non transparent parent
    - a different approach might be possible as well

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