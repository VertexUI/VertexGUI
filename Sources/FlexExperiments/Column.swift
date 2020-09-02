public class Column: Flex {

    public init(spacing: Double = 0, wrap: Bool = false, @Flex.ItemBuilder items buildItems: () -> [Item]) {

        super.init(orientation: .Column, spacing: spacing, wrap: wrap, items: buildItems())
    }
}