import WidgetGUI

public class TodoListView: SingleChildWidget {
    
    private var list: TodoList
    
    public init(for list: TodoList) {

        self.list = list 
    }

    override public func buildChild() -> Widget {

        Column(spacing: 16) {

            Text(list.name, fontSize: 32, fontWeight: .Bold, color: list.color)

            Column {

                for todo in list.items {

                    build(todo: todo)
                }
            }
        }
    }

    @FlexItemBuilder private func build(todo: TodoItem) -> [FlexItem] {

        Padding(all: 16) {
            
            Row(spacing: 48) {

                TaskCompletionButton(color: list.color)
                
                Row.Item(crossAlignment: .Center) {

                    Text(todo.description)
                }
            }
        }

        Column.Item(crossAlignment: .Stretch) {

            Padding(left: 40 + 48) {
            
                Divider(color: .Grey, axis: .Horizontal, width: 1)
            }
        }
    }
}