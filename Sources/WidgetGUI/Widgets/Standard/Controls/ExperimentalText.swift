import ReactiveProperties

public class ExperimentalText: TextBase {
  @ObservableProperty
  private var text: String

  public init(_ binding: ObservablePropertyBinding<String>) {
    self._text = binding
    super.init()
    self.displayedText = text
    _ = _text.onChanged { [unowned self] _ in
      displayedText = text
    }
  }

  public init(_ text: String) {
    self._text = StaticProperty(text)
    super.init()
    displayedText = text
  }
}