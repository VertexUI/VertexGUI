import VisualAppBase

public struct TodoItem {
    public static var nextTodoItemId = 0
    
    public var id: Int
    public var description: String
    public var images: [Image] = []
    public var completed = false

    public init(description: String) {
        self.id = Self.nextTodoItemId
        Self.nextTodoItemId += 1
        self.description = description
    }
}