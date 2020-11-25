//

//

import Foundation
import GfxMath

public struct FontConfig: Hashable {
    public var family: FontFamily
    public var size: Double 
    public var weight: FontWeight
    public var style: FontStyle

    public var face: FontFace {
        get {
            for face in family.faces {
                if face.weight == weight && face.style == style {
                    return face
                }
            }

            return family.faces[0]
        }
    }

    public init(family: FontFamily, size: Double, weight: FontWeight, style: FontStyle) {
        self.family = family
        self.size = size
        self.weight = weight
        self.style = style
    }

    public init(partial partialConfig: PartialFontConfig?, default defaultConfig: FontConfig) {
        self.family = partialConfig?.family ?? defaultConfig.family
        self.size = partialConfig?.size ?? defaultConfig.size
        self.weight = partialConfig?.weight ?? defaultConfig.weight
        self.style = partialConfig?.style ?? defaultConfig.style
    }
}

public struct PartialFontConfig {
    public var family: FontFamily?
    public var size: Double?
    public var weight: FontWeight?
    public var style: FontStyle?

    public init(
        family: FontFamily? = nil,
        size: Double? = nil,
        weight: FontWeight? = nil,
        style: FontStyle? = nil) {
            self.family = family
            self.size = size
            self.weight = weight
            self.style = style
    }

    public init(partials: [Self]) {
        for partial in partials {
            self.family = partial.family ?? self.family
            self.size = partial.size ?? self.size
            self.weight = partial.weight ?? self.weight
            self.style = partial.style ?? self.style
        }
    }
}