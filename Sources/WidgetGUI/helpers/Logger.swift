public class Logger { 
    public enum Level {
        case Debug, Message, Warning, Error
    }

    public static var activeLevels: [Level] = [
        .Debug
    ]

    public static func log(_ output: String, _ level: Level = .Debug) {
        if activeLevels.contains(level) {
            print(output)
        }
    }
}