import Foundation
import GfxMath

public protocol Blob {
    var id: UInt { get }

    var type: BlobType { get }

    var position: DVec2 { get set }

    /// Mass. In MassUnits.
    var mass: Double { get set }

    var radius: Double { get set }

    var consumed: Bool { get set }
}