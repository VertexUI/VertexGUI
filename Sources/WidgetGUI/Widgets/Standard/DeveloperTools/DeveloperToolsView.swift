import VisualAppBase
import CustomGraphicsMath

public class DeveloperToolsView: SingleChildWidget {
    public var debuggingData: RenderingDebuggingData? = nil {
        didSet {
            handleDebuggingDataUpdated()
        }
    }

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

            return Row {
                RenderGroupsTreeView(debuggingData: debuggingData)
                RenderGroupsListView(debuggingData: debuggingData)
            }
        }
        return Column {}
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