import Foundation
import CustomGraphicsMath

public struct TodoList {
    public var name: String
    public var color: Color
    public var items: [TodoItem]

    public var id: String {
        name
    }

    public static let mocks = [

        TodoList(name: "TestList 1", color: .Blue, items: [
            TodoItem(description: "Sweep the floor.", images: [
                try! Image(contentsOf: Bundle.module.url(forResource: "owl-2", withExtension: "jpg", subdirectory: "owl")!)
            ]),
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
        ])
    ]
}