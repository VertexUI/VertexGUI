import Foundation
import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public final class Text: Widget {
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

    public init(_ text: String, wrap: Bool = false) {
        self.text = text
        self.wrap = wrap
    }

    override public func performLayout() {
        if wrap {
            context!.getTextBoundsSize(text, fontConfig: fontConfig, maxWidth: bounds.size.width)
        } else {
            context!.getTextBoundsSize(text, fontConfig: fontConfig)
        }
    }

    override public func renderContent() -> RenderObject? {
        return .Text(text, fontConfig: fontConfig, color: .Black, topLeft: globalPosition, wrap: wrap, maxWidth: bounds.size.width)
    }
}
