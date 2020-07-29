//

//

import Foundation
import CustomGraphicsMath
import VisualAppBase

public class Text: Widget {
    public var text: String {
        didSet {
            layout()
        }
    }

    public var textConfigProvider: TextConfigProvider?
    public var textConfig: TextConfig?

    public var filledTextConfig: TextConfig {
        return textConfig ??
            textConfigProvider?.textConfig ?? 
            TextConfig(fontConfig: FontConfig(
                family: defaultFontFamily,
                size: 16,
                weight: .Regular,
                style: .Normal
            ), transform: .None, color: .Black, wrap: true)
    }

    public init(_ text: String, config: TextConfig? = nil) {
        self.text = text
        self.textConfig = config
        super.init()
        _ = onAnyParentChanged { _ in
            if let textConfigProvider = self.parentOfType(TextConfigProvider.self) {
                self.textConfigProvider = textConfigProvider
                // TODO: should the check be performed here?
                if self.layoutable {
                    self.layout()
                }
            }
        }
    }

    override public func layout() {
        //var size = try globalContext!.getTextSize(text: text, fontConfig: fontConfig)
        //self.sizeConfig.width = .Fixed(value: size.width)
        //self.sizeConfig.height = .Fixed(value: size.height)
        // TODO: check whether to have wrap in textConfig, or a property of Text and whether to pass maxWidth extra or put it into textconfig and whether to always pass it
        var preferredSize = DSize2.zero
        if filledTextConfig.wrap {
            preferredSize = context!.getTextBoundsSize(filledTextConfig.transform.apply(to: text), fontConfig: filledTextConfig.fontConfig, maxWidth: constraints!.maxWidth)// try context!.renderer.getMultilineTextSize(text, maxWidth: constraints!.maxWidth, fontConfig: textConfig.fontConfig)
        } else {
            preferredSize = context!.getTextBoundsSize(filledTextConfig.transform.apply(to: text), fontConfig: filledTextConfig.fontConfig)
        }
        bounds.size = constraints!.constrain(preferredSize)
    }

    /*override public func getContentSize() throws -> DSize2 {
        return try globalContext!.getTextSize(text: text, fontConfig: fontConfig)
    }*/

    override public func renderContent() -> RenderObject? {
        return .Text(filledTextConfig.transform.apply(to: text), fontConfig: filledTextConfig.fontConfig, color: filledTextConfig.color, topLeft: globalPosition, wrap: filledTextConfig.wrap, maxWidth: bounds.size.width)
    }
}