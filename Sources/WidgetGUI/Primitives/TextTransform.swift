public enum TextTransform {
    case Uppercase
    case Lowercase
    case Capitalize
    case None

    func apply(to string: String) -> String {
        switch self {
        case .Uppercase:
            return string.uppercased()
        case .Lowercase:
            return string.lowercased()
        case .Capitalize:
            return string.split(separator: " ").map {
                $0.count > 0 ? $0[0].uppercased() + $0[1...] : ""
            }.joined(separator: " ")
        case .None:
            return string
        }
    }
}