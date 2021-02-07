import GfxMath

public protocol ExperimentalDefaultStyleKeys {
}

public extension ExperimentalDefaultStyleKeys {
  static var padding: String {
    "padding"
  }
  static var foreground: String {
    "foreground"
  }
  static var background: String {
    "background"
  }
  static var borderWidth: String {
    "borderWidth"
  }
  static var borderColor: String {
    "borderColor"
  }
  static var opacity: String {
    "opacity"
  }
  static var visibility: String {
    "visibility"
  }
  static var overflow: String {
    "overflow"
  }
  static var textColor: String {
    "textColor"
  }
  static var textTransform: String {
    "textTransform"
  }
  static var wrapText: String {
    "wrapText"
  }
  static var fontSize: String {
    "fontSize"
  }
  static var fontWeight: String {
    "fontWeight"
  }
  static var fontStyle: String {
    "fontStyle"
  }
}

extension Experimental {
  public struct AnyDefaultStyleKeys: ExperimentalDefaultStyleKeys {
  }
}

extension Widget {
  public typealias StyleKeys = Experimental.AnyDefaultStyleKeys
}