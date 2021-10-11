import VertexGUI

public class TestWidget: ComposedWidget {
  @MutableBinding
  public var boundText: String

  public init(boundText: MutableBinding<String>) {
    self._boundText = boundText
  }

  @Compose override public var content: ComposedContent {
    Container().with(classes: ["container"]).withContent {
      TextInput(text: $boundText.mutable, placeholder: "placeholder").with(styleProperties: {
        (\.$foreground, .black)
      })
    }
  }
}