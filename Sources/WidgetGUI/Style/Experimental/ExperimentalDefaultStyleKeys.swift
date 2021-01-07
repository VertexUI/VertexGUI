public protocol ExperimentalDefaultStyleKeys {
  static var foreground: String { get }
}

extension ExperimentalDefaultStyleKeys {
  public static var foreground: String {
    "foreground"
  }
}

extension Experimental {
  public struct AnyDefaultStyleKeys: ExperimentalDefaultStyleKeys {
  }
}

extension Widget {
  public typealias StyleKeys = Experimental.AnyDefaultStyleKeys
}