import WidgetGUI

public class GameRulesetEditorView: SingleChildWidget {
    @Inject private var gameRuleset: Observable<GameRuleset>

    override open func buildChild() -> Widget {
        return Column {
            Row(crossAxisAlignment: .Center) {
                Text("foodBlobMass")

                TextField("\(gameRuleset.value.foodBlobMass)")
            }
        }
    }
}