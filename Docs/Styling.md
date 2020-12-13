# Styling

This document defines the styling functionality that should be provided by the framework.

At the moment it will the basis for implementing, later it will serve as documentation.

<br>

# Targetted Syntax

    Main {
      StyleProvider {
        Style(".button-text", Text.Style {
          $0.fontSize = 16
          $0.fontWeight = .bold
          $0.color = .red
        })

        Style(".button", Button.Style {
          $0.colorTransition = 
        })
      } {
        Column {
          Button {
            Text.with(class: "button-text")
          }

          Button {
            Text.with(class: "button-text")
          }

          Text().with(class: "description").with(style: Text.Style {
            $0.fontSize = 18
            $0.fontWeight = .normal
          })
        }
      }
    }