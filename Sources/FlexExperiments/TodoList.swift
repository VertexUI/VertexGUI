public struct TodoList {
    public var name: String
    public var items: [TodoItem]

    public static let mocks = [
        TodoList(name: "Test", items: [
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the other floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Don't sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor.")
        ])
    ]
}