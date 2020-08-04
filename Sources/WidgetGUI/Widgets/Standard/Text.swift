//

//

import Foundation
import CustomGraphicsMath
import VisualAppBase

public class Text: Widget {
    public struct PartialConfig {
        public var fontConfig: PartialFontConfig?
        public var transform: TextTransform?
        public var color: Color?
        public var wrap: Bool?
        
        public init(
            fontConfig: PartialFontConfig? = nil,
            transform: TextTransform? = nil,
            color: Color? = nil,
            wrap: Bool? = nil) {
                self.fontConfig = fontConfig
                self.transform = transform
                self.color = color
                self.wrap = wrap
        }
    }

    public struct Config: Hashable {
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

    public var text: String

    public static var defaultConfig = Config(
        fontConfig: FontConfig(
            family: defaultFontFamily,
            size: 16,
            weight: .Regular,
            style: .Normal
        ), transform: .None, color: .Black, wrap: true)

    public var textConfigProvider: TextConfigProvider?
    public var config: PartialConfig?

    public var filledConfig: Config {
        let ownConfig = config
        let providerConfig = textConfigProvider?.config
        let defaultConfig = Text.defaultConfig
    
        let fontConfig = FontConfig(
            family: ownConfig?.fontConfig?.family ?? providerConfig?.fontConfig?.family ?? defaultConfig.fontConfig.family,
            size: ownConfig?.fontConfig?.size ?? providerConfig?.fontConfig?.size ?? defaultConfig.fontConfig.size,
            weight: ownConfig?.fontConfig?.weight ?? providerConfig?.fontConfig?.weight ?? defaultConfig.fontConfig.weight,
            style: ownConfig?.fontConfig?.style ?? providerConfig?.fontConfig?.style ?? defaultConfig.fontConfig.style
        )

        return Config(
            fontConfig: fontConfig,
            transform: ownConfig?.transform ?? providerConfig?.transform ?? Text.defaultConfig.transform,
            color: ownConfig?.color ?? providerConfig?.color ?? Text.defaultConfig.color,
            wrap: ownConfig?.wrap ?? providerConfig?.wrap ?? Text.defaultConfig.wrap
        )
    }

    public init(_ text: String, config: PartialConfig? = nil) {
        self.text = text
        self.config = config
        super.init()
    }

    override open func performLayout() {
        // TODO: check whether to have wrap in config, or a property of Text and whether to pass maxWidth extra or put it into textconfig and whether to always pass it
        var preferredSize = DSize2.zero
        if filledConfig.wrap {
            preferredSize = context!.getTextBoundsSize(filledConfig.transform.apply(to: text), fontConfig: filledConfig.fontConfig, maxWidth: constraints!.maxWidth)// try context!.renderer.getMultilineTextSize(text, maxWidth: constraints!.maxWidth, fontConfig: config.fontConfig)
        } else {
            preferredSize = context!.getTextBoundsSize(filledConfig.transform.apply(to: text), fontConfig: filledConfig.fontConfig)
        }
        bounds.size = constraints!.constrain(preferredSize)
    }

    override public func renderContent() -> RenderObject? {
        return .Text(filledConfig.transform.apply(to: text), fontConfig: filledConfig.fontConfig, color: filledConfig.color, topLeft: globalPosition, wrap: filledConfig.wrap, maxWidth: bounds.size.width)
    }
}
