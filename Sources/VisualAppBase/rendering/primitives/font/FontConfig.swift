//

//

import Foundation
import CustomGraphicsMath

// TODO: maybe rename to Font?
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
}