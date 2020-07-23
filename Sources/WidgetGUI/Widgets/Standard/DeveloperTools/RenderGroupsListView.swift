import VisualAppBase

public class RenderGroupsListView: SingleChildWidget {
    private var debuggingData: RenderingDebuggingData
    
    public init(debuggingData: RenderingDebuggingData) {
        self.debuggingData = debuggingData
        super.init(child: )
    }
}