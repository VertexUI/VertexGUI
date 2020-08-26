import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class ExperimentThreeView: SingleChildWidget {

    private var todoLists = TodoList.mocks

    private var searchWidget: Widget?

    @Observable private var selectedList: TodoList? = nil

    override public func buildChild() -> Widget {

        Background(color: Color(230, 230, 230, 255)) { [unowned self] in

            Column(spacing: 32) {

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

        Column { [unowned self] in
            
            Column.Item(crossAlignment: .Stretch) {

                buildSearch()
            }

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
    }

    private func buildSearch() -> Widget {

        searchWidget = Background(color: Color(245, 245, 245, 255)) {

            Padding(all: 32) {

                Row {
                    
                    Background(color: Color(230, 230, 230, 255)) {

                        Padding(all: 8) {
                    
                            Text("Here will be the search!")
                        }
                    }
                }
            }
        }

        return searchWidget!
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

            Column {
                
                // TODO: maybe instead of using a variable, might use a child(where: ) function
                DependentSpace(dependency: searchWidget!) {

                    $0.globalBounds.size
                }

                Padding(all: 32) {

                    ObservingBuilder($selectedList) {

                        if let selectedList = selectedList {
                            
                            return TodoListView(for: selectedList)
                            
                        } else {

                            return Text("ACTIVE")
                        }
                    }
                }
            }
        }
    }

    override public func performLayout() {

        child.constraints = constraints // legacy

        child.bounds.size = constraints!.maxSize

        child.layout()

        bounds.size = child.bounds.size // legacy, needed to receive mouse events correctly
    }
}