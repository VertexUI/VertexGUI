public struct ItemType1 {

}

@_functionBuilder
public struct TestFunctionBuilder {
    /*public static func buildExpression(_ item: ItemType1) -> ItemType1 {
        [item]
    }*/

    /*public static func buildExpression(_ items: [ItemType1]) -> [ItemType1] {
        items
    }*/

    public static func buildArray(items: [ItemType1]) -> [ItemType1] {
        return items.compactMap { $0 }
    }

    public static func buildBlock(_ items: [ItemType1]) -> [ItemType1] {
        return items
    }
}

@TestFunctionBuilder func build() -> [ItemType1] {
    //ItemType1()
    //ItemType1()

    /*[
        ItemType1()
    ]*/

    [ItemType1()]
}