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

                    Button {
                        Text("Click this Button")
                    } onClick: { [unowned self] _ in
                        buttonClickCount += 1
                        sharedContent.value = "Content After Click On Button \(buttonClickCount) times"
                    }

                    Button  {
                        Text("Click this to invalidate the whole View.")
                    } onClick: { [unowned self] _ in
                        invalidateChild()
                    }
                }

                Space(size: DSize2(0, 100))

                ChildViewOne(content: sharedContent)
            }
        }
    }
}