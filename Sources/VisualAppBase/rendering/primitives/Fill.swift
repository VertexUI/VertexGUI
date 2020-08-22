import Swim
import CustomGraphicsMath

public enum Fill: Hashable {
    case Color(_ value: CustomGraphicsMath.Color)
    case Image(_ value: Image<RGB, UInt8>)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .Color(value):
            hasher.combine(value)
        case let .Image(value):
            hasher.combine(0) // TODO: provide real hashing
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