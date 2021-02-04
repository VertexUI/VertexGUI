public protocol ExperimentalDefaultStyleKeys {
  static var foreground: String { get }
}

public extension ExperimentalDefaultStyleKeys {
  static var foreground: String {
    "foreground"
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