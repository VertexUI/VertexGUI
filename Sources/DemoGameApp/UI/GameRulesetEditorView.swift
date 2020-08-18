import WidgetGUI

public class GameRulesetEditorView: SingleChildWidget {
    @Inject private var testString: String

    override open func buildChild() -> Widget {
        return Text(testString)
    }
}