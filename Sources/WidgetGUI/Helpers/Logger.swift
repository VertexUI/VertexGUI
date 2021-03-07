import ColorizeSwift

public class Logger {
    public static var enabled = false

    public static var activeLevels: Set<Level> = [
        .Message//, .Debug, .Warning, .Error
    ]

    public static var activeContexts: Set<Context> = [
        .Performance//, .Default, .WidgetLayouting, .WidgetRendering
    ]

    public static var renderer: LogRenderer = ConsoleLogRenderer()

    public static func log(_ outputs: @autoclosure () -> [LogText], level: Level, context: Context) {
        if !enabled {
            return
        }

        if activeContexts.contains(context) && activeLevels.contains(level) {
            renderer.log(["\(context) \(level): ".with(style: .bold)] + outputs())
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
        case Default, WidgetBuilding, WidgetLayouting, WidgetRendering, Performance
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
        case blue, white, yellow, green
    }

    public enum BackgroundColor {
        case blue, white, yellow, black, red
    }

    public enum FontStyle {
        case bold
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
                case .green:
                    partialString = partialString.green()
                case .yellow:
                    partialString = partialString.yellow()
                case .blue:
                    partialString = partialString.blue()
                case .white:
                    partialString = partialString.white()
                }
            }

            if let backgroundColor = text.backgroundColor {
                switch backgroundColor {
                case .blue:
                    partialString = partialString.onBlue()
                case .white:
                    partialString = partialString.onWhite()
                case .yellow:
                    partialString = partialString.onYellow()
                case .red:
                    partialString = partialString.onRed()
                case .black:
                    partialString = partialString.onBlack()
                }
            }

            if let fontStyle = text.fontStyle {
                switch fontStyle {
                case .bold:
                    partialString = partialString.bold()
                }
            }
            resultString += partialString
        }
        print(resultString)
    }
}
