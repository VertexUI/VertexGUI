import WidgetGUI

@_functionBuilder
public struct FlexItemBuilder {
    public static func buildExpression(_ widget: Widget) -> [FlexItem] {
        [FlexItem { widget }]
    }

    public static func buildExpression(_ widgets: [Widget]) -> [FlexItem] {
        widgets.map { widget in FlexItem { widget } }
    }

    public static func buildExpression(_ item: FlexItem) -> [FlexItem] {
        [item]
    }

    public static func buildExpression(_ items: [FlexItem]) -> [FlexItem] {
        items
    }

    public static func buildOptional(_ items: [FlexItem]?) -> [FlexItem] {

        return items ?? []
    }

    public static func buildBlock(_ items: [FlexItem]...) -> [FlexItem] {
        items.flatMap { $0 }
    }

    public static func buildArray(_ items: [[FlexItem]]) -> [FlexItem] {
        items.flatMap { $0 }
    }
}