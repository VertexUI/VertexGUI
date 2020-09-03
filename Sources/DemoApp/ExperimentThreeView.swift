import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class ExperimentThreeView: SingleChildWidget {

    private var todoLists = TodoList.mocks

    private var searchWidget: Widget?

    @Observable private var selectedList: TodoList? = nil

    override public func buildChild() -> Widget {

        Background(fill: Color(240, 240, 240, 255)) { [unowned self] in

            Column(spacing: 32) {

                Text("TODO Application", fontSize: 24, fontWeight: .Bold)

                Column.Item(grow: 1, crossAlignment: .Stretch) {

                    Row {
                        
                        Row.Item(crossAlignment: .Stretch) {
                       
                            buildMenu()
                        }

                        Row.Item(grow: 1, crossAlignment: .Stretch) {

                            buildActiveView()
                        }

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

            Column.Item(grow: 1, crossAlignment: .Stretch) {

                Padding(all: 32) {

                    Column(spacing: 24) {

                        Text("Lists", fontSize: 24, fontWeight: .Bold)

                        Column.Item(crossAlignment: .Stretch) {

                            Column {
                                
                                for list in todoLists {

                                    Column.Item(crossAlignment: .Stretch) {

                                        buildMenuListItem(for: list)
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
    }

    private func buildSearch() -> Widget {

        searchWidget = Background(fill: Color(245, 245, 245, 255)) {

            Padding(all: 32) {

                Row {
                    
                    Background(fill: Color(230, 230, 230, 255)) {

                        Padding(all: 8) {
                    
                            TextField("TEST TEXT")
                        }
                    }
                }
            }
        }

        return searchWidget!
    }

    private func buildMenuListItem(for list: TodoList) -> Widget {

        MouseArea {

            Background(fill: .White) {
                
                Padding(all: 16) {
                    
                    Row(spacing: 24) {
                        
                        Background(fill: list.color) {
                            
                            Padding(all: 8) {

                                MaterialIcon(.formatListBulletedSquare, color: .White)
                            }
                        }
                        
                        Row.Item(crossAlignment: .Center) {

                            Text(list.name)
                        }
                    }
                }
            }

        } onClick: { [unowned self] _ in

            selectedList = list
            
        }
    }

    private func buildActiveView() -> Widget {

        Background(fill: .White) { [unowned self] in

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
}