import GfxMath
import VisualAppBase

public class ColorPicker: SingleChildWidget {
  @MutableProperty
  public var color: Color

  public init(bind mutableColor: MutablePropertyBinding<Color>) {
    self._color = mutableColor
  }

  override public func buildChild() -> Widget {
    Column { [unowned self] in      
      Row(spacing: 32) {
        ColorFieldColorPicker(bind: $color.binding)

        Column {
          Text("RGBA")

          RGBATextColorPicker(bind: $color.binding)
        }

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
  internal class ColorFieldColorPicker: Widget, GUIMouseEventConsumer {
    @MutableProperty
    private var color: Color

    private lazy var saturationLightnessImage = generateSaturationLightnessImage()
    private lazy var hueImage = generateHueImage()

    private var saturationLightnessImageSize: ISize2 {
      ISize2(Int(width - 20), Int(height))
    }

    private var hueImageSize: ISize2 {
      ISize2(Int(20), Int(height))
    }

    private var saturationLightnessImagePosition: DPoint2 {
      globalPosition
    }

    private var hueImagePosition: DPoint2 {
      globalPosition + DVec2(Double(saturationLightnessImageSize.width), 0)
    }

    public init(bind mutableColor: MutablePropertyBinding<Color>) {
      self._color = mutableColor
      super.init()
      _ = self.onDestroy(self._color.onChanged { [unowned self] _ in
        invalidateRenderState()
      })
    }

    override public func getBoxConfig() -> BoxConfig {
      BoxConfig(preferredSize: DSize2(200, 200))
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      constraints.constrain(boxConfig.preferredSize)
    }

    public func consume(_ event: GUIMouseEvent) {
      if let event = event as? GUIMouseButtonClickEvent {
        if event.button == .Left {
          if event.position.x > hueImagePosition.x {
            let imagePosition = event.position - hueImagePosition
            let rawImageData = hueImage[Int(imagePosition.x), Int(imagePosition.y)]
            let rawColor = Color(r: rawImageData[0], g: rawImageData[1], b: rawImageData[2], a: 255)
            color = Color(h: rawColor.h, s: color.s, l: color.l, a: color.aFrac)
          } else {
            let imagePosition = event.position - saturationLightnessImagePosition
            let rawImageData = saturationLightnessImage[Int(imagePosition.x), Int(imagePosition.y)]
            let rawColor = Color(r: rawImageData[.red], g: rawImageData[.green], b: rawImageData[.blue], a: color.a)
            color = rawColor
          }
        }
      }
    }

    private func generateSaturationLightnessImage() -> Image {
      var saturationLightnessImage = Image(width: saturationLightnessImageSize.width, height: saturationLightnessImageSize.height, value: 0)

      for x in 0..<saturationLightnessImage.width {
        for y in 0..<saturationLightnessImage.height {
          let pxCol = Color(
            h: color.h,
            s: Double(x) / Double(saturationLightnessImage.width),
            l: max(
              0,
              1 - Double(y) / Double(saturationLightnessImage.height) - 0.5 * Double(x) / Double(saturationLightnessImage.width)),
            a: 1)
          saturationLightnessImage[x, y] = Image.Color(rgba: [pxCol.r, pxCol.g, pxCol.b, pxCol.a])
        }
      }

      return saturationLightnessImage
    }

    private func generateHueImage() -> Image {
      var hueImage = Image(width: hueImageSize.width, height: hueImageSize.height, value: 0)

      for x in 0..<hueImage.width {
        for y in 0..<hueImage.height {
          let color = Color(
            h: 360 * Double(y) / Double(hueImage.height),
            s: 1,
            l: 0.5,
            a: 1)
          hueImage[x, y] = Image.Color(rgba: [color.r, color.g, color.b, color.a])
        }
      }

      return hueImage
    }

    override public func renderContent() -> RenderObject? {
      /*if saturationLightnessImage.width != saturationLightnessImageSize.width ||
         saturationLightnessImage.height != saturationLightnessImageSize.height {*/
      saturationLightnessImage = generateSaturationLightnessImage()
      //}

      if hueImage.width != hueImageSize.width ||
         hueImage.height != hueImageSize.height {
          hueImage = generateHueImage()
      }

      return ContainerRenderObject {
        RenderStyleRenderObject(fill: FixedRenderValue(.Image(saturationLightnessImage, position: saturationLightnessImagePosition))) {
          RectangleRenderObject(DRect(min: saturationLightnessImagePosition, size: DSize2(saturationLightnessImageSize)))
        }

        RenderStyleRenderObject(fill: FixedRenderValue(.Image(hueImage, position: hueImagePosition))) {
          RectangleRenderObject(DRect(min: hueImagePosition, size: DSize2(hueImageSize)))
        }
      }
    }
  }

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
      Column { [unowned self] in
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