import WidgetGUI
import CustomGraphicsMath

public class ExperimentFourView: SingleChildWidget {

    override public func buildChild() -> Widget {
        
        Background(color: Color(200, 200, 255, 255)) {

            Padding(all: 32) {

                Row {

                    ConstrainedSize(maxSize: DSize2(400, .infinity)) {

                        Row {

                            Background(color: Color(140, 140, 255, 255)) {

                                Padding(all: 64) {

                                    Text("WORKS")
                                }
                            }

                            Text("A VEEEEEEEEEEEEEEERY LONG TEXT")
                        }

                    }.with {

                        $0.debugLayout = true
                    }

                }
            }
        }
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        child.constraints = self.constraints // legacy

        child.bounds.size = constraints.maxSize

        child.layout(constraints: constraints)

        return child.bounds.size
    }

    // TODO: remove this when the new layout approach is applied everywhere (Root should call layout(constraints: constraints))
    override public func layout() {

        layout(constraints: self.constraints!)
    }
}