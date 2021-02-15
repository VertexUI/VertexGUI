import GfxMath

extension Experimental {
  static let defaultStylePropertySupportDefinitions = Experimental.StylePropertySupportDefinitions {
    (AnyDefaultStyleKeys.foreground, type: .specific(Color.self), default: SpecialStyleValue.inherit)
  }
}