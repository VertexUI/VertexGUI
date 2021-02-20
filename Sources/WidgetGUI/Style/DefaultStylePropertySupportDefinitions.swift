import GfxMath
import VisualAppBase

let defaultStylePropertySupportDefinitions = StylePropertySupportDefinitions {
  (AnyDefaultStyleKeys.foreground, type: .specific(Color.self), default: SpecialStyleValue.inherit)
  (AnyDefaultStyleKeys.fontFamily, type: .specific(FontFamily.self), default: SpecialStyleValue.inherit)
  (AnyDefaultStyleKeys.fontSize, type: .specific(Double.self), default: SpecialStyleValue.inherit)
}