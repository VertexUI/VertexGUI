import WidgetGUI

public class GameRulesetEditorView: SingleChildWidget {
    @Inject private var gameRuleset: Observable<GameRuleset>

    override open func buildChild() -> Widget {
        return Column(spacing: 64, horizontalAlignment: .Stretch) { [unowned self] in

            buildPropertyEdit(label: "food blob mass") {
                TextField("\(gameRuleset.value.foodBlobMass)") {
                    if let value = Double($0) {
                        gameRuleset.value.foodBlobMass = value
                    }
                }
            }

            buildPropertyEdit(label: "targetted food density") {
                TextField("\(gameRuleset.value.targettedFoodDensity)") {
                    if let value = Double($0) {
                        gameRuleset.value.targettedFoodDensity = value
                    }
                }
            }

            buildPropertyEdit(label: "food generation rate") {
                TextField("\(gameRuleset.value.foodGenerationRate)") {
                    if let value = Double($0), value.isFinite {
                        gameRuleset.value.foodGenerationRate = value
                    }
                }
            }
        }
    }

    private func buildPropertyEdit(label: String, @WidgetBuilder input: () -> Widget) -> Widget {
        return Row(spacing: 32) {
            Row.Item(grow: 1, verticalAlignment: .Center) {
                Text(label)
            }

            input()
        }
    }
}