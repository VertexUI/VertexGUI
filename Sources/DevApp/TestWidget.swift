import SwiftGUI

public class TestWidget: ContentfulWidget {
  @Experimental.MutableBinding
  public var boundText: String

  public init(boundText: Experimental.MutableBinding<String>) {
    self._boundText = boundText
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().with(classes: ["container"]).withContent {
      TextInput(mutableText: $boundText.mutable, placeholder: "placeholder").experimentalWith(styleProperties: {
        (\.$foreground, .black)
      })
    }
  }
}