import SwiftGUI

public class TestWidget: ContentfulWidget {
  @MutableBinding
  public var boundText: String

  public init(boundText: MutableBinding<String>) {
    self._boundText = boundText
  }

  @DirectContentBuilder override public var content: DirectContent {
    Container().with(classes: ["container"]).withContent {
      TextInput(text: $boundText.mutable, placeholder: "placeholder").with(styleProperties: {
        (\.$foreground, .black)
      })
    }
  }
}