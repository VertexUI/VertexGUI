import CustomGraphicsMath

public struct TodoList {
    public var name: String
    public var color: Color
    public var items: [TodoItem]

    public static let mocks = [
        TodoList(name: "Test", color: .Blue, items: [
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