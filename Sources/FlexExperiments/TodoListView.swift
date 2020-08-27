import WidgetGUI

public class TodoListView: SingleChildWidget {

    // TODO: maybe do something with WidgetRef, as a variable inside a widget which will
    // always contain the current child widget that received the ref object in build
    
    private var list: TodoList

    private var expandedItemIndices: Set<Int> = []
    
    public init(for list: TodoList) {

        self.list = list

        super.init()

        self.debugLayout = true
    }

    override public func buildChild() -> Widget {

        Column(spacing: 16) {

            Text(list.name, fontSize: 32, fontWeight: .Bold, color: list.color)

            Column {

                for (index, todo) in list.items.enumerated() {

                    build(todo: todo, index: index)
                }
            }
        }
    }

    @FlexItemBuilder private func build(todo: TodoItem, index: Int) -> [FlexItem] {

        MouseArea {

            Padding(all: 16) {
                
                Column {

                    Row(spacing: 48) {

                        TaskCompletionButton(color: list.color)
                        
                        Row.Item(crossAlignment: .Center) {

                            Text(todo.description)
                        }
                    }

                    if expandedItemIndices.contains(index) {

                        Text("ExPANDdeD")
                    }
                }
            }

        } onClick: { [unowned self] _ in

            withChildInvalidation {

                expandedItemIndices.insert(index)
            }
        }

        Column.Item(crossAlignment: .Stretch) {

            Padding(left: 40 + 48) {
            
                Divider(color: .Grey, axis: .Horizontal, width: 1)
            }
        }
    }
}