# RichText

This document defines the target syntax for rich text definition and styling.

Currently it serves as a reference for implementation, later it will serve as documentation.

<br>

# Target Syntax

    RichText {
      "This"; ImageView(); "is an "; Text("image").with(class: "highlight")

      "Images convey visual information to whoever sees them."
    }.with(style: RichText.Style {

    }.sub {
      Text.Style(".highlight") {
        $0.color = .blue
      }
    })