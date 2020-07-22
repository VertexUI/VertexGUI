@_functionBuilder
public struct WidgetBuilder {
    public static func buildBlock(_ widget: Widget) -> Widget {
        return widget
    }

    public static func buildBlock(_ widget: Widget) -> [Widget] {
        return [widget]
    }

    public static func buildBlock(_ widgets: Widget?...) -> [Widget] {
        return widgets.compactMap { $0 }
    }

    public static func buildBlock(_ widgets: [Widget?]) -> [Widget] {
        return widgets.compactMap { $0 }
    }

    public static func buildOptional(_ widget: Widget?) -> Widget? {
        return widget
    }

    public static func buildEither(first: Widget) -> Widget {
        return first
    }

    public static func buildEither(second: Widget) -> Widget {
        return second
    }

    /*public static func buildBlock(_ widgets: [Widget?]...) -> [Widget] {
        return widgets.flatMap { $0 }.compactMap { $0 }
    }*/
}