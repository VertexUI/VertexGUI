import GfxMath

let defaultStylePropertySupportDefinitions = StylePropertySupportDefinitions {
  (AnyDefaultStyleKeys.foreground, type: .specific(Color.self), default: SpecialStyleValue.inherit)
}