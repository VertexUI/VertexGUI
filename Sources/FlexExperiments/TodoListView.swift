import WidgetGUI

public class TodoListView: SingleChildWidget {
    
    private var list: TodoList
    
    public init(for list: TodoList) {

        self.list = list 
    }

    override public func buildChild() -> Widget {

        Column {

            for todo in list.items {

                build(todo: todo)
            }
        }
    }

    private func build(todo: TodoItem) -> Widget {

        Text(todo.description)
    }
}