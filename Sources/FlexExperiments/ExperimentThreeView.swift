import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class ExperimentThreeView: SingleChildWidget {

    private var todoLists = TodoList.mocks

    @Observable private var selectedList: TodoList? = nil

    override public func buildChild() -> Widget {

        Background(color: Color(230, 230, 230, 255)) { [unowned self] in

            Column {

                Text("TODO Applikation", fontSize: 24, fontWeight: .Bold)

                Column.Item(grow: 1, crossAlignment: .Stretch) {

                    Row {
                    
                        buildMenu()

                        Row.Item(grow: 1, crossAlignment: .Stretch) {

                            buildActiveView()
                        }

                    }.with {

                        $0.debugLayout = true
                    }
                }
            }
        }
    }

    private func buildMenu() -> Widget {

        Padding(all: 32) {

            Column {

                Text("Lists", fontSize: 24, fontWeight: .Bold)

                Column {
                    
                    for list in todoLists {

                        buildMenuListItem(for: list)
                    }
                }
            }
        }
    }

    private func buildMenuListItem(for list: TodoList) -> Widget {

        MouseArea {

            Background(color: .White) {
                
                Padding(all: 16) {

                    Text(list.name)
                }
            }

        } onClick: { [unowned self] _ in

            print("IT WAS CLICKED!")

            selectedList = list
            
        }.with {

            $0.debugLayout = true
        }
    }

    private func buildActiveView() -> Widget {

        Background(color: .White) { [unowned self] in

            ObservingBuilder($selectedList) {

                if let selectedList = selectedList {
                    
                    return TodoListView(for: selectedList)
                    
                } else {

                    return Text("ACTIVE")
                }
            }
        }
    }

    override public func performLayout() {

        child.constraints = constraints // legacy

        child.bounds.size = constraints!.maxSize

        child.layout()

        bounds.size = child.bounds.size
    }
}