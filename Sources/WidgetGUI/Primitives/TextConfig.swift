import CustomGraphicsMath
import VisualAppBase

// TODO: might rename to TextStyle / could also add to VisualAppBase?
// TODO: or is this the first Widget Config instead of parameter list?
public struct TextConfig: Hashable {
    public var fontConfig: FontConfig
    public var transform: TextTransform
    public var color: Color
    public var wrap: Bool
    
    public init(fontConfig: FontConfig, transform: TextTransform, color: Color, wrap: Bool) {
        self.fontConfig = fontConfig
        self.transform = transform
        self.color = color
        self.wrap = wrap
    }
}