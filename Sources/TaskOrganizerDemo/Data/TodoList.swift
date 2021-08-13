import Foundation
import GfxMath

public protocol TodoListProtocol {
    var id: Int { get }
    var name: String { get }
    var color: Color { get }
    var items: [TodoItem] { get }
}

public struct TodoList: TodoListProtocol, Equatable {
    public var id: Int
    public var name: String
    public var color: Color
    public var items: [TodoItem]

    public func filtered(by query: String) -> TodoList {
        let filteredItems = items.filter { $0.description.lowercased().contains(query.lowercased()) }
        return TodoList(id: id, name: name, color: color, items: filteredItems)
    }

    /*public static let mocks = [

        TodoList(name: "TestList 1", color: .blue, items: [
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor. Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the other floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Don't sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            /*TodoItem(description: "Sweep the other floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Sweep the floor."),
            TodoItem(description: "Don't sweep the floor."),
            TodoItem(description: "Sweep the floor."),
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
            TodoItem(description: "Sweep the floor.")*/
        ]),

        TodoList(name: "TestList 2", color: .orange, items: [
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
        ]),

        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList4", color: .black, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
        TodoList(name: "TestList3", color: .green, items: []),
    ]*/
}