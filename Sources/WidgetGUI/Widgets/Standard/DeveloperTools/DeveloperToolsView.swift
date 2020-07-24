import VisualAppBase
import CustomGraphicsMath

public class DeveloperToolsView: SingleChildWidget, StatefulWidget {
    public var debuggingData: RenderingDebuggingData? = nil {
        didSet {
            handleDebuggingDataUpdated()
        }
    }

    public struct State {
        public var selectedObjectPath: TreePath?
    }
    
    public var state: State = State()

    public init() {
        super.init(child: Column(children: []))
    }

    private func invalidateChild() {
        var child = buildChild()
        child.parent = self
        // TODO: maybe dangling closure
        _ = child.onRenderStateInvalidated {
            self.invalidateRenderState($0)
        }
        self.child = child
        try! layout(fromChild: false)
        invalidateRenderState()
    }

    private func handleDebuggingDataUpdated() {
        /*if let debuggingData = debuggingData {
            expandedGroupIndices = Set(0..<debuggingData.groups.count)
        }
        selectedObjectPath = nil*/
        invalidateChild()
        //self.invalidateRenderState()
    }

    private func buildChild() -> Widget {
        print("DEBUUGER CALL UPDATE CHILD")

        if let debuggingData = debuggingData {
            print("HAVE DEBUGGING DATA")

            //print("GROUP COUNT", groups.count)

            return Background(background: .White) {
                Column {
                    ScrollArea {
                        RenderGroupsTreeView(debuggingData: debuggingData, selectedObjectPath: state.selectedObjectPath) {
                            self.state.selectedObjectPath = $1
                            self.invalidateChild()
                        }
                    }
                    buildSelectedObjectDetail()
                    //RenderGroupsListView(debuggingData: debuggingData)
                }
            }
        }
        return Column {}
    }

    private func buildSelectedObjectDetail() -> Widget {
        var children = [Widget]()
        if let selectedObjectPath = state.selectedObjectPath {
            print("BUILD SELECTED DETAIL!!!", selectedObjectPath)
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
/*
    private func onObjectClick(_ object: RenderObject, at path: TreePath) {
        self.selectedObjectPath = path 
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
    }*/

    override open func render(_ renderedChild: RenderObject?) -> RenderObject? {
        return RenderObject.Uncachable {
            renderedChild
        }
    }
}