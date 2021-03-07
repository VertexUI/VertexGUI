@_functionBuilder
public struct WidgetBuilder {
    public static func buildBlock() -> [Widget] {
        return []
    }
    
    public static func buildBlock(_ widget: Widget) -> Widget {
        return widget
    }

    public static func buildExpression(_ widget: Widget) -> Widget {
        return widget
    }

    public static func buildExpression(_ widget: Widget) -> [Widget] {
        return [widget]
    }

    public static func buildExpression(_ widgets: [Widget]) -> [Widget] {
        return widgets
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

    public static func buildBlock(_ widgets: [Widget?]...) -> [Widget] {
        return widgets.flatMap { $0 }.compactMap { $0 }
    }
    
    /*public static func buildBlock(_ widget: Widget, _ widgets2: [Widget?]) -> [Widget] {
        return [widget] + widgets2.compactMap { $0 }
    }    */

    public static func buildOptional(_ widget: Widget?) -> Widget? {
        return widget
    }

    public static func buildOptional(_ widget: Widget?) -> [Widget] {
        return widget != nil ? [widget!] : []
    }


    public static func buildEither(first: Widget) -> Widget {
        return first
    }

    /*public static func buildEither(first: Widget) -> [Widget] {
        return [first]
    }*/

    public static func buildEither(first: [Widget]) -> [Widget] {
        return first
    }



    public static func buildEither(second: Widget) -> Widget {
        return second
    }

    /*public static func buildEither(second: Widget) -> [Widget] {
        return [second]
    }*/

    public static func buildEither(second: [Widget]) -> [Widget] {
        return second
    }


    /*public static func buildBlock(_ widgets: [Widget?]...) -> [Widget] {
        return widgets.flatMap { $0 }.compactMap { $0 }
    }*/
}