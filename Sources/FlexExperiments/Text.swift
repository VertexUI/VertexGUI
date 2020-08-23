import Foundation
import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public final class Text: Widget, BoxWidget {
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

    public func getBoxConfig() -> BoxConfig {
        let preferredSize: DSize2
        if wrap {
            preferredSize = context!.getTextBoundsSize(text, fontConfig: fontConfig, maxWidth: bounds.size.width)
        } else {
            preferredSize = context!.getTextBoundsSize(text, fontConfig: fontConfig)
        }
        return BoxConfig(preferredSize: preferredSize)
    }

    override public func performLayout() {

    }

    override public func renderContent() -> RenderObject? {
        .Text(text, fontConfig: fontConfig, color: .Black, topLeft: globalPosition, wrap: wrap, maxWidth: bounds.size.width)
    }
}
