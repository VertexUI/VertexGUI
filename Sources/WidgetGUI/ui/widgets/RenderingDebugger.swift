import VisualAppBase
import CustomGraphicsMath

public class RenderingDebugger: SingleChildWidget {
    public var debuggingData: RenderingDebuggingData? = nil {
        didSet {
            handleDebuggingDataUpdated()
        }
    }
    public var expandedGroupIndices: Set<Int> = []
    public var selectedObject: RenderObject?

    public init() {
        super.init(child: Column(children: []))
    }

    private func handleDebuggingDataUpdated() {
        if let debuggingData = debuggingData {
            expandedGroupIndices = Set(0..<debuggingData.groups.count)
        }
        updateChild()
        self.invalidateRenderState()
    }

    private func updateChild() {
        print("DEBUUGER CALL UPDATE CHILD")

        if let debuggingData = debuggingData {
            print("HAVE DEBUGGING DATA")

            let groups: [Widget?] = (0..<debuggingData.groups.count).flatMap {
                [self.build(groupIndex: $0), Space(size: DSize2(0, 40))]
            }

            print("GROUP COUNT", groups.count)


            self.child = Background(background: .White) {
                Row {
                    Column {
                        groups.compactMap { $0 }
                    }
                    buildSelectedObjectDetail()
                }
            }
            self.child.parent = self
            // TODO: maybe dangling closure

            _ = child.onRenderStateInvalidated {
                self.invalidateRenderState($0)
            }
            try! self.layout(fromChild: false)
        }
    }

    private func buildSelectedObjectDetail() -> Widget {
        var children = [Widget]()
        if let selectedObject = selectedObject {
            var properties = [Widget]()
            let mirror = Mirror(reflecting: selectedObject)
            for child in mirror.children {
                if let label = child.label {
                    properties.append(Text("\(label): \(child.value)"))
                }
            }
            children.append(contentsOf: properties)
        } else {
            //return Space(size: DSize2.zero)
        }
        return Column {
            Text("Detail View for \(String(describing: selectedObject))")
            children
        }
    }

    private func build(object: RenderObject, in range: TreeRange) -> Widget {
        var children = [Widget]()
        if let object = object as? SubTreeRenderObject {
            children.append(contentsOf: object.children.map {
                self.build(object: $0, in: range)
            })
        }
        
        let background: Color
        if let selectedObject = selectedObject {
            background = type(of: selectedObject) == type(of: object) && selectedObject.individualHash == object.individualHash ? Color(255, 230, 230, 255) : Color(240, 240, 255, 255)
        } else {
            background = Color(240, 240, 255, 255)
        }

        return Column {
            MouseArea(onClick: { _ in self.onObjectClick(object) }) {
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
            build(object: debuggingData!.tree, in: range)
        }
    }

    private func build(groupIndex: Int) -> Widget {
        let group = debuggingData!.groups[groupIndex]
        return Column {
            MouseArea(onMouseButtonDown: { _ throws -> Void in
                print("CLICK")
                if self.expandedGroupIndices.contains(groupIndex) {
                    self.expandedGroupIndices.remove(groupIndex)
                } else {
                    self.expandedGroupIndices.insert(groupIndex)
                }
                self.updateChild()
                self.invalidateRenderState()
            }) {
                Text("RenderGroup \(group.id)")
            }
            if expandedGroupIndices.contains(groupIndex) {
                if let treeRange = group.treeRange {
                    build(range: treeRange)
                } else {
                    Text("empty")
                }
            }
        }
    }

    private func onObjectClick(_ object: RenderObject) {
        self.selectedObject = object
        self.updateChild()
        self.invalidateRenderState()
    }

    override open func layout(fromChild: Bool) throws {
        print("DEBUGGER CALLED LAYOUT", bounds.size, constraints, self.child.bounds.size)
        child.constraints = constraints 
        try child.layout()
        //child.bounds.size = DSize2(100, 100)
        bounds.size = child.bounds.size
        print("DEBUGGER LAYOUT FINISHED", bounds.size)
    }

    override open func render(_ renderedChild: RenderObject?) -> RenderObject? {
        return RenderObject.Uncachable {
            renderedChild
        }
    }
}