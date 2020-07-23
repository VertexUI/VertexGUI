import VisualAppBase
import CustomGraphicsMath

public class RenderGroupsListView: SingleChildWidget, StatefulWidget {
    public struct State {
        public var expandedGroupIndices: Set<Int> = []
        public var selectedObjectPath: TreePath?
    }
    
    public var state: State = State()
    private var debuggingData: RenderingDebuggingData?
    
    public init(debuggingData: RenderingDebuggingData?) {
        self.debuggingData = debuggingData
        if let debuggingData = debuggingData {
            self.state.expandedGroupIndices = Set(0..<debuggingData.groups.count)
        }
        super.init(child: Text("Works"))
        var child = buildChild()
        child.parent = self
        // TODO: maybe dangling closure
        _ = child.onRenderStateInvalidated {
            self.invalidateRenderState($0)
        }
        self.child = child
    }

    private func invalidateChild() {
        var child = buildChild()
        child.parent = self
        // TODO: maybe dangling closure
        _ = child.onRenderStateInvalidated {
            print("CHILD RENDER STATE INVALIDATED")
            self.invalidateRenderState($0)
        }
        self.child = child
        try! layout(fromChild: false)
        invalidateRenderState()
    }

    private func buildChild() -> Widget {
        print("DEBUUGER CALL UPDATE CHILD")

        if let debuggingData = debuggingData {
            print("HAVE DEBUGGING DATA")

            let groups: [Widget?] = (0..<debuggingData.groups.count).flatMap {
                [self.build(groupIndex: $0), Space(size: DSize2(0, 40))]
            }

            print("GROUP COUNT", groups.count)

            return Background(background: .White) {
                Row {
                    ScrollArea {
                        Column {
                            Background(background: .Blue) {
                                Space(size: DSize2(400, 400))
                            }
                            groups.compactMap { $0 }
                        }
                    }
                    buildSelectedObjectDetail()
                }
            }
        }

        return Column {}
    }

    private func buildSelectedObjectDetail() -> Widget {
        var children = [Widget]()
        if let selectedObjectPath = state.selectedObjectPath {
            let selectedObject = debuggingData!.tree[selectedObjectPath]!
            var properties = [Widget]()
            let mirror = Mirror(reflecting: selectedObject)
            for child in mirror.children {
                if let label = child.label {
                    properties.append(Text("\(label): \(child.value)"))
                }
            }
            children.append(contentsOf: properties)
        
            return Column {
                Text("Detail View for \(String(describing: selectedObject))")
                children
            }
        } else {
            return Column {}
        }
    }

    private func build(object: RenderObject, at path: TreePath, in range: TreeRange) -> Widget {
        var children = [Widget]()
        if let object = object as? SubTreeRenderObject {
            for i in 0..<object.children.count {
                children.append(self.build(object: object.children[i], at: path/i, in: range))
            }
        }
        
        let background: Color
        if let selectedObjectPath = state.selectedObjectPath {
            background = path == selectedObjectPath ? Color(255, 230, 230, 255) : Color(240, 240, 255, 255)
        } else {
            background = Color(240, 240, 255, 255)
        }

        return Column {
            MouseArea(onClick: { _ in self.onObjectClick(object, at: path) }) {
                Background(background: background) {
                    Padding(padding: Insets(16)) {
                        Text(String(describing: object))
                    }
                }
            }
            Row {
                Space(size: DSize2(40, 0))
                Column {
                    children
                }
            }
        }
    }

    private func build(range: TreeRange) -> Widget {
        return Column {
            Text("Range")
            Text("Start: \(range.start.debugDescription)")
            Text("End: \(range.start.debugDescription)")
            build(object: debuggingData!.tree, at: TreePath(), in: range)
        }
    }

    private func build(groupIndex: Int) -> Widget {
        let group = debuggingData!.groups[groupIndex]
        return Column {
            MouseArea(onMouseButtonDown: { _ throws -> Void in
                print("CLICK")
                if self.state.expandedGroupIndices.contains(groupIndex) {
                    self.state.expandedGroupIndices.remove(groupIndex)
                } else {
                    self.state.expandedGroupIndices.insert(groupIndex)
                }
                self.invalidateChild()
            }) {
                Text("RenderGroup \(group.id)")
            }
            if state.expandedGroupIndices.contains(groupIndex) {
                if let treeRange = group.treeRange {
                    build(range: treeRange)
                } else {
                    Text("empty")
                }
            }
        }
    }

    private func onObjectClick(_ object: RenderObject, at path: TreePath) {
        self.state.selectedObjectPath = path 
        self.invalidateChild()
    }

    override open func render(_ renderedChild: RenderObject?) -> RenderObject? {
        return RenderObject.Uncachable {
            renderedChild
        }
    }
}