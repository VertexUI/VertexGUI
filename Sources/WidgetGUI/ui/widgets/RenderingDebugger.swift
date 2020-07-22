import VisualAppBase
import CustomGraphicsMath

public class RenderingDebugger: SingleChildWidget {
    public var debuggingData: RenderingDebuggingData? = nil {
        didSet {
            handleDebuggingDataUpdated()
            self.invalidateRenderState()
        }
    }
    public var expandedGroupIndices: Set<Int> = []

    public init() {
        super.init(child: Column {})
    }

    private func handleDebuggingDataUpdated() {
        if let debuggingData = debuggingData {
            expandedGroupIndices = Set(0..<debuggingData.groups.count)
            updateChild()
        }
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
                Column {
                    groups
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

    private func build(object: RenderObject, in range: TreeRange) -> Widget {
        var children = [Widget]()
        if let object = object as? SubTreeRenderObject {
            children.append(contentsOf: object.children.map {
                self.build(object: $0, in: range)
            })
        }
        
        return Column {
            Background(background: Color(240, 240, 255, 255)) {
                Padding(padding: Insets(16)) {
                    Text(String(describing: object))
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
            MouseArea(on: (buttonDown: { _ throws -> Void in
                print("CLICK")
                if self.expandedGroupIndices.contains(groupIndex) {
                    self.expandedGroupIndices.remove(groupIndex)
                } else {
                    self.expandedGroupIndices.insert(groupIndex)
                }
                self.updateChild()
                self.invalidateRenderState()
            }, click: nil, move: nil)) {
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