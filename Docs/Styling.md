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