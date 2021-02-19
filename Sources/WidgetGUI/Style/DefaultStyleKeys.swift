import GfxMath

public protocol DefaultStyleKeys {
}

public extension DefaultStyleKeys {
  static var width: String {
    "width"
  }
  static var height: String {
    "height"
  }
  static var minWidth: String {
    "minWidth"
  }
  static var minHeight: String {
    "minHeight"
  }
  static var maxWidth: String {
    "maxWidth"
  }
  static var maxHeight: String {
    "maxHeight"
  }
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
  static var overflowX: String {
    "overflowX"
  }
  static var overflowY: String {
    "overflowY"
  }
  static var textTransform: String {
    "textTransform"
  }
  static var wrapText: String {
    "wrapText"
  }
  static var fontFamily: String {
    "fontFamily"
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
  static var transform: String {
    "transform"
  }
}

public struct AnyDefaultStyleKeys: DefaultStyleKeys {
}

extension Widget {
  public typealias StyleKeys = AnyDefaultStyleKeys
}