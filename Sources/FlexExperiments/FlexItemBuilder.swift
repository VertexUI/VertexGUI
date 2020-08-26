import WidgetGUI

@_functionBuilder
public struct FlexItemBuilder {
    public static func buildExpression(_ widget: Widget) -> FlexItem {
        return FlexItem { widget }
    }

    public static func buildExpression(_ item: FlexItem) -> FlexItem {
        return item
    }

    public static func buildBlock(_ items: FlexItem...) -> [FlexItem] {
        return items
    }

    public static func buildBlock(_ items: [FlexItem]) -> [FlexItem] {
        return items
    }

    public static func buildArray(_ items: [[FlexItem]]) -> [FlexItem] {
        return items.flatMap { $0 }
    }
}