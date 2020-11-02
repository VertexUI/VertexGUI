//

//

import Foundation
import CustomGraphicsMath

// ------
// UNUSED
// --------
public struct RenderStyle {
    public var fillColor: Color?
    public var strokeWidth: Double?
    public var strokeColor: Color?

    public init(fillColor: Color? = nil, strokeWidth: Double? = nil, strokeColor: Color? = nil) {
        self.fillColor = fillColor
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
    }
}