import WidgetGUI
import CustomGraphicsMath
import ColorizeSwift

public class ExperimentFourView: SingleChildWidget {

    @Observable private var longText: String = "This is the first veeeeery looooong text"

    override public func buildChild() -> Widget {
        
        /*Background(color: Color(200, 200, 255, 255)) {

            Padding(all: 32) {*/
            
            MouseArea { [unowned self] in

                ConstrainedSize(maxSize: DSize2(200, .infinity)) {

                    Row(wrap: true) {

                            Text("WOW This text is long but doesn't wrap")
                            
                            ObservingBuilder($longText) {
                                
                                ConstrainedSize(minSize: DSize2(100, 0)) {

                                    Text(longText, wrap: true).with {

                                        $0.debugLayout = true

                                    }
                                }
                            }.with { observer in

                                _ = observer.onBoxConfigChanged {

                                    print("OBSERVER BOX CONFIG CHANGED".yellow(), $0, observer.previousConstraints)
                                }
                            }

                            Text("This is the text after")
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
                        $0.layoutDebuggingColor = .Blue

                        _ = $0.onBoxConfigChanged {
                            print("ROW BOX CONFIG CHANGEd", $0)
                        }
                    }
                }

            } onClick: { [unowned self] in

                switch $0.button {

                case .Left:
                    longText = "This is the second veeeeeeeeeeeeeeeeeeeeery looooooooooooooong text that is even longer"

                case .Right:
                    invalidateRenderState()
                }
            }.with {

                $0.debugLayout = true
            }
        //}
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        //child.constraints = constraints // legacy

        //child.bounds.size = constraints.maxSize

        child.layout(constraints: constraints)

        //print("CHILD DID LAYOUT", child.bounds.size, constraints)

        return child.bounds.size
    }

    // TODO: remove this when the new layout approach is applied everywhere (Root should call layout(constraints: constraints))
    override public func layout() {

        layout(constraints: self.constraints!)
    }
}