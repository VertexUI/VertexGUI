import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

public class MainView: SingleChildWidget {
    private let sharedContent = Observable<String>("Initial Content From MainView")
    private var buttonClickCount = 0
    
    override open func buildChild() -> Widget {
        Padding(all: 100) {
            Column {
                Column {
                    Text("MainView")

                    Button(onClick: { _ in
                        self.buttonClickCount += 1
                        self.sharedContent.value = "Content After Click On Button \(self.buttonClickCount) times"

                        var test = Text("WOWOWO")
                        test.text = "slslsd"
                    }) {
                        Text("Click this Button")
                    }

                    Button(onClick: { _ in
                        self.invalidateChild()
                        
                    }) {
                        Text("Click this to invalidate the child.")
                    }
                }

                Space(size: DSize2(0, 100))

                ChildViewOne(content: sharedContent)
            }
        }
    }
}