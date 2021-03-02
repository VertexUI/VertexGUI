import SwiftGUI

public class TestWidget: ContentfulWidget {
  @Experimental.ImmutableBinding
  public var boundText: String

  public init(boundText: Experimental.ImmutableBinding<String>) {
    self._boundText = boundText
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().with(classes: ["container"]).withContent {
      Text($boundText.immutable).experimentalWith(styleProperties: {
        (\.$foreground, .black)
      })
    }
  }
}