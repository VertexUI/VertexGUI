import CustomGraphicsMath
import Foundation

public struct BoxConstraints: Equatable, CustomDebugStringConvertible {

    public var minSize: DSize2

    public var maxSize: DSize2

    public var debugDescription: String {
        "BoxConstraints { min: \(minWidth) x \(minHeight) | max: \(maxWidth) x \(maxHeight) }"
    }

    // TODO: maybe add overflow property to indicate whether overflowing is allowed instead of using infinity in maxSize?
    public init(minSize: DSize2, maxSize: DSize2) {

        self.minSize = minSize

        self.maxSize = maxSize
    }

    public init(size: DSize2) {

        self.minSize = size

        self.maxSize = size
    }

    public var minWidth: Double {

        get {

            return minSize.width
        }

        set {

            minSize.width = newValue
        }
    }

    public var minHeight: Double {

        get {

            return minSize.height
        }

        set {

            minSize.height = newValue
        }
    }

    public var maxWidth: Double {

        get {

            return maxSize.width
        }

        set {

            maxSize.width = newValue
        }
    }

    public var maxHeight: Double {

        get {

            return maxSize.height
        }

        set {

            maxSize.height = newValue
        }
    }

    public func constrain(_ size: DSize2) -> DSize2 {

        return DSize2(min(max(size.width, minSize.width), maxSize.width), min(max(size.height, minSize.height), maxSize.height))
    }
}