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

        public init(partials: [PartialConfig]) {
            var fontConfigs = [PartialFontConfig]()
            for partial in partials {
                if let partial = partial.fontConfig {
                    fontConfigs.append(partial)
                }
                self.transform = partial.transform ?? self.transform
                self.color = partial.color ?? self.color
                self.wrap = partial.wrap ?? self.wrap
            }
            self.fontConfig = PartialFontConfig(partials: fontConfigs)
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

        public init(partial partialConfig: PartialConfig?, default defaultConfig: Config) {
            self.fontConfig = FontConfig(partial: partialConfig?.fontConfig, default: defaultConfig.fontConfig)
            self.transform = partialConfig?.transform ?? defaultConfig.transform
            self.color = partialConfig?.color ?? defaultConfig.color
            self.wrap = partialConfig?.wrap ?? defaultConfig.wrap
        }
    }

    public var text: String {
        didSet {
            if oldValue != text {
                performLayout()
                invalidateRenderState()
            }
        }
    }

    public static var defaultConfig = Config(
        fontConfig: FontConfig(
            family: defaultFontFamily,
            size: 16,
            weight: .Regular,
            style: .Normal
        ), transform: .None, color: .Black, wrap: true)

    weak public var textConfigProvider: TextConfigProvider?
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
        _ = onAnyParentChanged { [unowned self] _ in
            textConfigProvider = parentOfType(TextConfigProvider.self)
        }
    }

    public convenience init(
        _ text: String,
        fontFamily: FontFamily? = nil,
        fontSize: Double? = nil,
        fontWeight: FontWeight? = nil,
        fontStyle: FontStyle? = nil,
        transform: TextTransform? = nil,
        color: Color? = nil,
        wrap: Bool? = nil
        ) {
            self.init(text, config: PartialConfig(
                fontConfig: PartialFontConfig(
                    family: fontFamily,
                    size: fontSize,
                    weight: fontWeight,
                    style: fontStyle
                ),
                transform: transform,
                color: color,
                wrap: wrap
            ))
    }

    override open func performLayout() {
        var preferredSize = DSize2.zero

        let transformedText = filledConfig.transform.apply(to: text)

        if transformedText.isEmpty {
         
            preferredSize.height = context!.getTextBoundsSize(" ", fontConfig: filledConfig.fontConfig).height
        
        } else {

            if filledConfig.wrap {
                preferredSize = context!.getTextBoundsSize(transformedText, fontConfig: filledConfig.fontConfig, maxWidth: constraints!.maxWidth)
            } else {
                preferredSize = context!.getTextBoundsSize(transformedText, fontConfig: filledConfig.fontConfig)
            }
        }

        preferredSize.width += 1

        bounds.size = constraints!.constrain(preferredSize)
    }

    /// This function is used in TextInput to get the coordinates where the caret should be displayed.
    /// - Returns: The local bounding rect (origin: self -> topLeft) up to (including) the specified index inside the text.
    /// - Parameter to: Up to which character index (including the index) to return the bounds.
    /// - Misc:
    /// TODO: maybe put this somewhere else
    public func getSubBounds(to index: Int) -> DRect {
        var preferredSize = DSize2.zero

        let partialText = text.substring(to: text.index(text.startIndex, offsetBy: index))
        let transformedText = filledConfig.transform.apply(to: partialText)

        if transformedText.isEmpty {
         
            preferredSize.height = context!.getTextBoundsSize(" ", fontConfig: filledConfig.fontConfig).height
        
        } else {

            if filledConfig.wrap {
                preferredSize = context!.getTextBoundsSize(transformedText, fontConfig: filledConfig.fontConfig, maxWidth: constraints!.maxWidth)
            } else {
                preferredSize = context!.getTextBoundsSize(transformedText, fontConfig: filledConfig.fontConfig)
            }
        }

        return DRect(min: .zero, max: DVec2(preferredSize))
    }

    override public func renderContent() -> RenderObject? {
        return .Text(filledConfig.transform.apply(to: text), fontConfig: filledConfig.fontConfig, color: filledConfig.color, topLeft: globalPosition, wrap: filledConfig.wrap, maxWidth: bounds.size.width)
    }
}
