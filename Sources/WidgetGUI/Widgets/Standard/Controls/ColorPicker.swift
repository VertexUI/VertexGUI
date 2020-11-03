import CustomGraphicsMath

public class ColorPicker: SingleChildWidget {
  @MutableProperty
  public var color: Color

  public init(bind mutableColor: MutablePropertyBinding<Color>) {
    self._color = mutableColor
  }

  override public func buildChild() -> Widget {
    Column { [unowned self] in
      Row {
        Text("RGBA")

        RGBATextColorPicker(bind: $color.binding)

        ObservingBuilder($color) {
          Background(fill: color) {
            Space(DSize2(80, 50))
          }
        }
      }
    }
  }
}

extension ColorPicker {
  internal class RGBATextColorPicker: SingleChildWidget {
    @MutableProperty
    public var color: Color
    @MutableProperty
    private var redText: String = ""
    @MutableProperty
    private var greenText: String = ""
    @MutableProperty
    private var blueText: String = ""
    @MutableProperty
    private var alphaText: String = ""

    public init(bind mutableColor: MutablePropertyBinding<Color>) {
      self._color = mutableColor
      let color = mutableColor.value
      super.init()
      checkUpdateTexts()
      _ = onDestroy(self.$color.onChanged { [unowned self] _ in checkUpdateTexts() })
      _ = self.$redText.onChanged { [unowned self] _ in checkUpdateColor() }
      _ = self.$greenText.onChanged { [unowned self] _ in checkUpdateColor() }
      _ = self.$blueText.onChanged { [unowned self] _ in checkUpdateColor() }
      _ = self.$alphaText.onChanged { [unowned self] _ in checkUpdateColor() }
    }

    override public func buildChild() -> Widget {
      Row { [unowned self] in
        Text("R:")
        TextField(bind: $redText)
        Text("G:")
        TextField(bind: $greenText)
        Text("B:")
        TextField(bind: $blueText)
        Text("A:")
        TextField(bind: $alphaText)
      }
    }

    private func checkUpdateTexts() {
      self.redText = String(color.r)
      self.greenText = String(color.g)
      self.blueText = String(color.b)
      self.alphaText = String(color.a)
    }

    private func checkUpdateColor() {
      guard let r = UInt8(redText) else { return }
      guard let g = UInt8(greenText) else { return }
      guard let b = UInt8(blueText) else { return }
      guard let a = try UInt8(alphaText) else { return }
      color = Color(r, g, b, a)
    }
  }
}