import CustomGraphicsMath
import Foundation

public struct BoxConstraints {
    public var minSize: DSize2
    public var maxSize: DSize2

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
    }

    public var minHeight: Double {
        get {
            return minSize.height
        }
    }

    public var maxWidth: Double {
        get {
            return maxSize.width
        }
    }

    public var maxHeight: Double {
        get {
            return maxSize.height
        }
    }

    public func constrain(_ size: DSize2) -> DSize2 {
        return DSize2(min(max(size.width, minSize.width), maxSize.width), min(max(size.height, minSize.height), maxSize.height))
    }
}