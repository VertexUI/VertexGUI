# Styling

This document defines the styling functionality that should be provided by the framework.

At the moment it will the basis for implementing, later it will serve as documentation.

<br>

# Targetted Syntax

    Main {
      // the styles inserted by StyleProvider should only be checked for a
      // selector match with the children of StyleProvider, Widgets outside of it
      // remain unaffected by the provided styles,
      // even if their selectors match
      StyleProvider {
        Text.Style(".button-text") {
          $0.fontSize = 16
          $0.fontWeight = .bold
          $0.color = .black
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
              $0.color = .white
            }
          }

          // it should be possible to perform matching by checking all
          // Widgets with a custom match function
          Button.Style("&:hover", { ($0 as? Button)?.text == "button1" }) {
            // the transition defined in the $:hover style above should apply here as well,
            $0.background = Color.orange
          }.sub {
            Text.Style {
              $0.color = .yellow
            }
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
        }
      }
    }

# Needing Clarification

- are styles reactive? and if so at what level? at each property? or for each Style element, and where do the dependencies for the reactive calculation come from? from the Widget --> properties?

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