import ColorizeSwift

public class Logger {

    public static var activeLevels: Set<Level> = [

        .Message, .Debug, .Warning, .Error
    ]

    public static var activeContexts: Set<Context> = [

        .Default, .WidgetLayouting, .WidgetRendering
    ]

    public static var renderer: LogRenderer = ConsoleLogRenderer()

    public static func log(_ outputs: LogText..., level: Level, context: Context) {

        if activeContexts.contains(context) && activeLevels.contains(level) {
            
            renderer.log(["\(context) \(level): "] + outputs)
        }
    }

    public static func debug(_ output: String, context: Context = .Default) {

        log(LogText(stringInterpolation: output), level: .Debug, context: context)
    }
    
    public static func warn(_ output: String, context: Context = .Default) {

        log(LogText(stringInterpolation: output), level: .Warning, context: context)
    }

    public enum Level: CaseIterable {
        
        case Debug, Message, Warning, Error
    }

    public enum Context: CaseIterable {

        case Default, WidgetLayouting, WidgetRendering
    }
}

public struct LogText: ExpressibleByStringInterpolation {

    public let value: String

    public private(set) var backgroundColor: BackgroundColor?

    public private(set) var foregroundColor: ForegroundColor?

    public private(set) var fontStyle: FontStyle?

    /*public init(stringLiteral value: StaticString) {

        self.value = value.description
    }*/

    public init(stringInterpolation value: String) {

        self.value = value
    }

    public init(stringLiteral value: String) {

        self.value = value
    }
/*
    public init(unicodeScalarLiteral value: StaticString) {

        self.value = value.description
    }

    public init(extendedGraphemeClusterLiteral value: StaticString) {
        
        self.value = value.description
    }*/

    public func with(bg: BackgroundColor? = nil, fg: ForegroundColor? = nil, style: FontStyle? = nil) -> Self {

        var result = LogText(stringLiteral: value)

        if let backgroundColor = bg {

            result.backgroundColor = backgroundColor
        }

        if let foregroundColor = fg {

            result.foregroundColor = foregroundColor
        }

        if let style = style {

            result.fontStyle = style
        }

        return result
    }

    public enum ForegroundColor {

        case Blue, White, Yellow, Green
    }

    public enum BackgroundColor {

        case Blue, White, Yellow
    }

    public enum FontStyle {

        case Bold
    }
}

extension String {

    public func with(bg: LogText.BackgroundColor? = nil, fg: LogText.ForegroundColor? = nil, style: LogText.FontStyle? = nil) -> LogText {

        LogText(stringLiteral: self).with(bg: bg, fg: fg, style: style)
    }
}

public protocol LogRenderer {

    func log(_ texts: [LogText])
}

public struct ConsoleLogRenderer: LogRenderer {

    public func log(_ texts: [LogText]) {
        
        var resultString = ""

        for text in texts {
            
            var partialString = text.value

            if let foregroundColor = text.foregroundColor {

                switch foregroundColor {

                case .Green:

                    partialString = partialString.green()
                    
                case .Yellow:

                    partialString = partialString.yellow()

                case .Blue:

                    partialString = partialString.blue()

                default:

                    fatalError("Unsupported LogText foreground color in ConsoleLogRenderer: \(foregroundColor).")
                }
            }

            if let fontStyle = text.fontStyle {

                switch fontStyle {

                case .Bold:

                    partialString = partialString.bold()

                default:

                    fatalError("Unsupported LogText font style in ConsoleLogRenderer: \(fontStyle).")
                }
            }

            resultString += partialString
        }

        print(resultString)
    }
}