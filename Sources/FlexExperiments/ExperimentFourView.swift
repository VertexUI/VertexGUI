import WidgetGUI
import CustomGraphicsMath

public class ExperimentFourView: SingleChildWidget {

    @Observable private var longText: String = "This is the first veeeeery looooong text"

    override public func buildChild() -> Widget {
        
        /*Background(color: Color(200, 200, 255, 255)) {

            Padding(all: 32) {*/

            ConstrainedSize(maxSize: DSize2(200, .infinity)) { [unowned self] in

                Row {

                        Text("WOW")
                        
                        ObservingBuilder($longText) {

                            Text(longText, wrap: true)
                        }
                        /*Row {

                            Background(color: Color(140, 140, 255, 255)) {

                                Padding(all: 64) {

                                    Text("WORKS")
                                }
                            }

                            Text("A VEEEEEEEEEEEEEEERY LONG TEXT").with {
                                
                                $0.debugLayout = false
                            }

                        }.with {

                            $0.debugLayout = true
                        }*/

                    /*}.with {

                        $0.debugLayout = false
                    }*/

                }.with {

                    $0.debugLayout = true
                }
            }
        //}
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        //child.constraints = constraints // legacy

        //child.bounds.size = constraints.maxSize

        print("CALL LAYOUT!")

        child.layout(constraints: constraints)

        print("CHILD DID LAYOUT", child.bounds.size)

        return child.bounds.size
    }

    // TODO: remove this when the new layout approach is applied everywhere (Root should call layout(constraints: constraints))
    override public func layout() {

        layout(constraints: self.constraints!)
    }
}