import Foundation
import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public final class Text: Widget, CustomDebugStringConvertible {
    public var text: String {
        didSet {
            if oldValue != text {
                layout()
                invalidateRenderState()
            }
        }
    }

    public var wrap: Bool

    private var fontConfig = FontConfig(
        family: defaultFontFamily,
        size: 24,
        weight: .Regular,
        style: .Normal   
    )

    public var debugDescription: String {
        "Text \(text)"
    }

    public init(_ text: String, fontSize: Double = 24, fontWeight: FontWeight = .Regular, wrap: Bool = false) {
        self.text = text
        self.wrap = wrap
        self.fontConfig.size = fontSize
        self.fontConfig.weight = fontWeight
    }

    override public func getBoxConfig() -> BoxConfig {
        var config = BoxConfig(preferredSize: context!.getTextBoundsSize(text, fontConfig: fontConfig))

        if !wrap {
            config.minSize = config.preferredSize
        }

        return config
    }

    override public func performLayout() {

    }

    override public func renderContent() -> RenderObject? {
        .Text(text, fontConfig: fontConfig, color: .Black, topLeft: globalPosition, wrap: wrap, maxWidth: bounds.size.width)
    }
}
