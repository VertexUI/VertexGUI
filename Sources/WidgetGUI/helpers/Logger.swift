import ColorizeSwift

public class Logger {

    public static var enabled = false

    public static var activeLevels: Set<Level> = [

        .Message, .Debug, .Warning, .Error
    ]

    public static var activeContexts: Set<Context> = [

        .Default, .WidgetLayouting, .WidgetRendering
    ]

    public static var renderer: LogRenderer = ConsoleLogRenderer()

    public static func log(_ outputs: @autoclosure () -> [LogText], level: Level, context: Context) {

        if !enabled {
            
            return
        }

        if activeContexts.contains(context) && activeLevels.contains(level) {
            
            renderer.log(["\(context) \(level): ".with(style: .Bold)] + outputs())
        }
    }

    public static func log(_ output: @autoclosure () -> LogText, level: Level, context: Context) {

        log([output()], level: level, context: context)
    }
    
    public static func log(_ output1: @autoclosure () -> LogText, _ output2: @autoclosure () -> LogText, level: Level, context: Context) {
        
        log([output1(), output2()], level: level, context: context)
    }

    public static func debug(_ output: @autoclosure () -> LogText, context: Context = .Default) {

        log([output()], level: .Debug, context: context)
    }
    
    public static func warn(_ output: @autoclosure () -> LogText, context: Context = .Default) {

        log([output()], level: .Warning, context: context)
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

    public init(stringInterpolation value: String) {

        self.value = value
    }

    public init(stringLiteral value: String) {

        self.value = value
    }

    public func with(fg: ForegroundColor? = nil, bg: BackgroundColor? = nil, style: FontStyle? = nil) -> Self {

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

        case Blue, White, Yellow, Black, Red
    }

    public enum FontStyle {

        case Bold
    }
}

extension String {

    public func with(fg: LogText.ForegroundColor? = nil, bg: LogText.BackgroundColor? = nil, style: LogText.FontStyle? = nil) -> LogText {

        LogText(stringLiteral: self).with(fg: fg, bg: bg, style: style)
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

                case .White:

                    partialString = partialString.white()
                }
            }

            if let backgroundColor = text.backgroundColor {

                switch backgroundColor {

                case .Blue:

                    partialString = partialString.onBlue()

                case .White:

                    partialString = partialString.onWhite()

                case .Yellow:

                    partialString = partialString.onYellow()

                case .Red:

                    partialString = partialString.onRed()

                case .Black:

                    partialString = partialString.onBlack()
                }
            }

            if let fontStyle = text.fontStyle {

                switch fontStyle {

                case .Bold:

                    partialString = partialString.bold()
                }
            }

            resultString += partialString
        }

        print(resultString)
    }
}
