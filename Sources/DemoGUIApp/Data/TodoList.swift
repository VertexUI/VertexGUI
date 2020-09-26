import Foundation
import CustomGraphicsMath
import VisualAppBase

public struct TodoList {

    public var name: String

    public var color: Color

    public var items: [TodoItem]

    public var id: String {

        name
    }

    public func filtered(by query: String) -> TodoList {

        let filteredItems = items.filter { $0.description.contains(query) }

        return TodoList(name: name, color: color, items: filteredItems)
    }

    public static let mocks = [

        TodoList(name: "TestList 1", color: .Blue, items: [
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

        TodoList(name: "TestList 2", color: .Orange, items: [
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

        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList4", color: .Black, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
        TodoList(name: "TestList3", color: .Green, items: []),
    ]
}