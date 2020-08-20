import WidgetGUI

public class GameRulesetEditorView: SingleChildWidget {
    @Inject private var gameRuleset: Observable<GameRuleset>

    lazy private var bufferedRuleset = gameRuleset.value

    override open func buildChild() -> Widget {
        return Column(spacing: 64, horizontalAlignment: .Stretch) { [unowned self] in

            buildPropertyEdit(label: "food blob mass") {
                TextField("\(bufferedRuleset.foodBlobMass)") {
                    if let value = Double($0) {
                        bufferedRuleset.foodBlobMass = value
                    }
                }
            }

            buildPropertyEdit(label: "targetted food density") {
                TextField("\(bufferedRuleset.targettedFoodDensity)") {
                    if let value = Double($0) {
                        bufferedRuleset.targettedFoodDensity = value
                    }
                }
            }

            buildPropertyEdit(label: "food generation rate") {
                TextField("\(bufferedRuleset.foodGenerationRate)") {
                    if let value = Double($0), value.isFinite {
                        bufferedRuleset.foodGenerationRate = value
                    }
                }
            }

            Button {
                Text("Apply")
            } onClick: { _ in
                gameRuleset.value = bufferedRuleset
            }
        }
    }

    private func buildPropertyEdit(label: String, @WidgetBuilder input: () -> Widget) -> Widget {
        return Row(spacing: 32) {
            Row.Item(grow: 1, verticalAlignment: .Center) {
                Text(label, fontSize: 16)
            }

            input()
        }
    }
}