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

    private var wrap: Bool

    private var color: Color

    private var fontConfig = FontConfig(
        family: defaultFontFamily,
        size: 24,
        weight: .Regular,
        style: .Normal   
    )

    public var debugDescription: String {
        "TextWidget: \"\(text)\""
    }

    public init(_ text: String, fontSize: Double = 24, fontWeight: FontWeight = .Regular, fontFamily: FontFamily? = nil, wrap: Bool = false, color: Color = .Black) {
        self.text = text
        self.wrap = wrap
        self.color = color
        self.fontConfig.size = fontSize
        self.fontConfig.weight = fontWeight
        if let fontFamily = fontFamily {
            self.fontConfig.family = fontFamily
        }
    }

    override public func getBoxConfig() -> BoxConfig {
        var config = BoxConfig(preferredSize: context!.getTextBoundsSize(text, fontConfig: fontConfig))

        if !wrap {
            config.minSize = config.preferredSize
        }

        return config
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        let textBoundsSize = context!.getTextBoundsSize(text, fontConfig: fontConfig, maxWidth: wrap ? constraints.maxWidth : nil)

        //print("CALLING LAYOUT ON TEXT", constraints)

        return textBoundsSize
    }

    override public func renderContent() -> RenderObject? {
        .Text(text, fontConfig: fontConfig, color: color, topLeft: globalPosition, wrap: wrap, maxWidth: bounds.size.width)
    }
}
