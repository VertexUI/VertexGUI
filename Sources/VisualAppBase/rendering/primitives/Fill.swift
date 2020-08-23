import Swim
import CustomGraphicsMath

public enum Fill: Hashable {
    case Color(_ value: CustomGraphicsMath.Color)
    case Image(_ value: Image<RGBA, UInt8>, position: DVec2)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .Color(value):
            hasher.combine(value)
        case let .Image(value, position):
            hasher.combine(0) // TODO: provide real hashing
            hasher.combine(position)
        }
    }
}

/*public protocol Fill: Hashable {}

public struct AnyFill: Fill {
    public let wrapped: Any
    private var hashWrapped: (_ hasher: inout Hasher) -> Void
    
    public init<F: Fill>(_ wrapped: F) {
        self.wrapped = wrapped
        self.hashWrapped = {
            wrapped.hash(into: &$0)
        }
    }

    public func hash(into hasher: inout Hasher) {
        hashWrapped(&hasher)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return false
    }
}*/