import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class ExperimentThreeView: SingleChildWidget {

    private var todoLists = TodoList.mocks

    @Observable private var selectedList: TodoList? = nil

    override public func buildChild() -> Widget {

        Background(color: .White) { [unowned self] in

            Column {

                Text("TODO Applikation", fontSize: 24, fontWeight: .Bold)

                Row {
                    
                    buildMenu()

                    buildActiveView()                    
                }
            }
        }
    }

    private func buildMenu() -> Widget {

        Column {

            Text("Lists", fontSize: 24, fontWeight: .Bold)

            Column {
                
                for list in todoLists {

                    buildMenuListItem(for: list)
                }
            }
        }
    }

    private func buildMenuListItem(for list: TodoList) -> Widget {

        MouseArea {

            Background(color: Color(0, 0, 0, 30)) {
                
                Padding(all: 16) {

                    Text(list.name)
                }
            }

        } onClick: { [unowned self] _ in

            print("IT WAS CLICKED!")
            selectedList = list
        }
    }

    private func buildActiveView() -> Widget {

        ObservingBuilder($selectedList) { [unowned self] in

            if let selectedList = selectedList {
                
                return Text("HAVE LIST")
                
            } else {

                return Text("ACTIVE")

            }
        }
    }

    override public func performLayout() {

        child.constraints = constraints // legacy

        child.bounds.size = constraints!.maxSize

        child.layout()
    }
}