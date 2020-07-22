import VisualAppBase
import CustomGraphicsMath

public class RenderingDebugger: SingleChildWidget {
    public var debuggingData: RenderingDebuggingData? = nil {
        didSet {
            updateChild()
            self.invalidateRenderState()
        }
    }

    public init() {
        super.init(child: Column {
            Button {
                Text("WOW A BUTTON")
            }
        })
    }

    private func updateChild() {
        print("DEBUUGER CALL UPDATE CHILD")

        if let debuggingData = debuggingData {
            print("HAVE DEBUGGING DATA")

            let groups: [Widget?] = debuggingData.groups.flatMap {
                [self.build(group: $0), Space(size: DSize2(0, 40))]
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
            Text(String(describing: object))
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

    private func build(group: RenderGroup) -> Widget {
        return Column {
            Text("RenderGroup \(group.id)")
            if let treeRange = group.treeRange {
                build(range: treeRange)
            } else {
                Text("empty")
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
}