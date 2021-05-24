import Swim

public struct TodoItem: Equatable {
    public static var nextTodoItemId = 0
    
    public var id: Int
    public var listId: Int
    public var description: String
    public var images: [Image<RGBA, UInt8>] = []
    public var completed = false

    public init(listId: Int, description: String) {
        self.id = Self.nextTodoItemId
        self.listId = listId
        Self.nextTodoItemId += 1
        self.description = description
    }
}