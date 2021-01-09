import GfxMath
import VisualAppBase

public protocol StyleValue {
}

extension Int: StyleValue {}
extension Double: StyleValue {}
extension Bool: StyleValue {}
extension Insets: StyleValue {}
extension GfxMath.Color: StyleValue {}
extension TextTransform: StyleValue {}
extension VisualAppBase.FontWeight: StyleValue {}
extension VisualAppBase.FontStyle: StyleValue {}