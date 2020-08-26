import WidgetGUI

public class TodoListView: SingleChildWidget {
    
    private var list: TodoList
    
    public init(for list: TodoList) {

        self.list = list 
    }

    override public func buildChild() -> Widget {

        Column {

            Text(list.name, fontSize: 24, fontWeight: .Bold)

            for todo in list.items {

                build(todo: todo)
            }

        }.with {
            
            $0.debugLayout = true
        }
    }

    private func build(todo: TodoItem) -> Widget {

        Text(todo.description)
    }

    override public func performLayout() {

        print("LAYOUTING TODO LIST VIEW", bounds.size)
        
        super.performLayout()
    }
}