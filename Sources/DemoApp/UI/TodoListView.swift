import WidgetGUI

public class TodoListView: SingleChildWidget {

    // TODO: maybe do something with WidgetRef, as a variable inside a widget which will
    // always contain the current child widget that received the ref object in build
    
    private var list: TodoList

    private var expandedItemIndices: Set<Int> = []
    
    public init(_ list: TodoList) {

        self.list = list
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

    @Flex.ItemBuilder private func build(todo: TodoItem, index: Int) -> [Flex.Item] {

        MouseArea {

            Padding(all: 16) {
                
                Column(spacing: 24) {

                    Row(spacing: 48) {

                        TaskCompletionButton(color: list.color)
                        
                        Row.Item(crossAlignment: .Center) {

                            Text(todo.description, wrap: true)
                        }
                        
                    }

                    if expandedItemIndices.contains(index) {

                        Row {

                            todo.images.map {

                                ImageView(image: $0)
                            }
                        }
                    }
                }
            }

        } onClick: { [unowned self] _ in

            if todo.images.count > 0 {

                withChildInvalidation {

                    expandedItemIndices.insert(index)
                }
            }
        }

        Column.Item(crossAlignment: .Stretch) {

            Padding(left: 40 + 48) {
            
                Divider(color: .Grey, axis: .Horizontal, thickness: 1)
            }
        }
    }
}