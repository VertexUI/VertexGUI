public enum TextTransform {
    case uppercase
    case lowercase
    case capitalize
    case none

    func apply(to string: String) -> String {
        switch self {
        case .uppercase:
            return string.uppercased()
        case .lowercase:
            return string.lowercased()
        case .capitalize:
            return string.split(separator: " ").map {
                $0.count > 0 ? $0[0].uppercased() + $0[1...] : ""
            }.joined(separator: " ")
        case .none:
            return string
        }
    }
}