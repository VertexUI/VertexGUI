public class Logger { 
    public enum Level: CaseIterable {
        case Debug, Message, Warning, Error
    }

    public static var activeLevels: [Level] = [
        .Debug, .Warning, .Error
    ]

    public static func log(_ level: Level = .Debug, _ output: String) {
        if activeLevels.contains(level) {
            print("\u{001B}[1;33m\(level):\u{001B}[0;0m", output, "\u{001B}[0;0m")
        }
    }

    public static func debug(_ output: String) {
        log(.Debug, output)
    }
}