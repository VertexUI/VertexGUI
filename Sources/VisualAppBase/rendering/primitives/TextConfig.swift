import CustomGraphicsMath
import VisualAppBase

// TODO: might rename to TextStyle / could also add to VisualAppBase?
// TODO: or is this the first Widget Config instead of parameter list?
public struct TextConfig: Hashable {
    public var fontConfig: FontConfig
    public var color: Color
    public var wrap: Bool
    
    public init(fontConfig: FontConfig, color: Color, wrap: Bool) {
        self.fontConfig = fontConfig
        self.color = color
        self.wrap = wrap
    }
}