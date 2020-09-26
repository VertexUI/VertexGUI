import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class TodoAppView: SingleChildWidget {

    public enum Mode {

        case SelectedList, Search
    }

    private var todoLists = TodoList.mocks

    private var searchWidget: Widget?

    @Observable private var selectedList: TodoList? = nil

    @Observable private var mode: Mode = .SelectedList

    @Observable private var searchQuery: String = ""

    override public func buildChild() -> Widget {

        DependencyProvider(provide: [

            Dependency(todoLists)

        ]) {

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
    }

    private func buildMenu() -> Widget {

        Column { [unowned self] in
            
            Column.Item(crossAlignment: .Stretch) {

                buildSearch()
            }

            Column.Item(grow: 1, crossAlignment: .Stretch) {

                ScrollArea {

                    Padding(all: 32) {

                        Column(spacing: 24) {

                            Text("Lists", fontSize: 24, fontWeight: .Bold)

                            Column.Item(crossAlignment: .Stretch) {

                                Column {
                                    
                                    todoLists.map { list in

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
    }

    private func buildSearch() -> Widget {

        searchWidget = Background(fill: .White) { [unowned self] in

            Padding(all: 32) {

                ConstrainedSize(minSize: DSize2(300, 0), maxSize: DSize2(300, .infinity)) {

                    Padding(all: 8) {
    
                        Row(spacing: 24) {
                        
                            Row.Item(grow: 1) {

                                TextField {

                                    searchQuery = $0

                                }.onFocusChanged.chain {
                                    
                                    if $0 {
                                        
                                        mode = .Search
                                    }
                                }
                            }

                            Row.Item(crossAlignment: .Center) {

                                ObservingBuilder($mode) {

                                    if mode == .Search {

                                        return MouseArea {
                                        
                                            Button {

                                                Text("cancel")
                                            }

                                        } onClick: { _ in

                                            mode = .SelectedList                                            
                                        }

                                    } else {

                                        return Space(.zero)
                                    }
                                }
                            }
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

            mode = .SelectedList            
        }
    }

    private func buildActiveView() -> Widget {

        Background(fill: .White) { [unowned self] in

            Column {
                
                // TODO: maybe instead of using a variable, might use a child(where: ) function
                DependentSpace(dependency: searchWidget!) {

                    $0.globalBounds.size
                }

                Column.Item(grow: 1, crossAlignment: .Stretch) {

                    Padding(all: 32) {

                        ObservingBuilder($mode) {

                            switch mode {

                            case .SelectedList:

                                ObservingBuilder($selectedList) {

                                    if let selectedList = selectedList {
                                        
                                        return TodoListView(selectedList)
                                        
                                    } else {

                                        return Center {

                                            Text("No list selected.", fontSize: 24, fontWeight: .Bold, color: .Grey)
                                        }
                                    }
                                }
                            
                            case .Search:

                                SearchResultsView(query: $searchQuery)
                            }
                        }
                    }
                }
            }
        }
    }
}
