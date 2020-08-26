public struct TodoList {
    public var name: String
    public var items: [TodoItem]

    public static let mocks = [
        TodoList(name: "Test", items: [])
    ]
}