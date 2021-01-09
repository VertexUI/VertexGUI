import GfxMath

public protocol StyleValue {
}

extension Int: StyleValue {}
extension Double: StyleValue {}
extension Insets: StyleValue {}
extension GfxMath.Color: StyleValue {}