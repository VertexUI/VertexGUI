import Foundation
import WidgetGUI
import CustomGraphicsMath
import ColorizeSwift

public class ExperimentFourView: SingleChildWidget {

    @Observable private var longText: String = "This is the first veeeeery looooong text"

    override public func buildChild() -> Widget {
        
        /*Background(color: Color(200, 200, 255, 255)) {

            Padding(all: 32) {*/
            
            MouseArea { [unowned self] in

                ConstrainedSize(maxSize: DSize2(300, .infinity)) {

                    Row(wrap: true) {

                        Text("WOW This text is long but doesn't wrap")
                        
                        ObservingBuilder($longText) {
                            
                            ConstrainedSize(minSize: DSize2(100, 0)) {

                                Text(longText, wrap: true)
                            }
                        }

                        Text("This is the text after")

                        Row {

                            Background(color: Color(140, 140, 255, 255)) {

                                Padding(all: 64) {

                                    Text("WORKS")
                                }.with {

                                    $0.debugLayout = true
                                }
                            }

                            Text("A VEEEEEEEEEEEEEEERY LONG TEXT")

                        }

                        ImageView(

                            image: try! Image(
                                
                                contentsOf: Bundle.module.url(

                                    forResource: "owl", withExtension: "jpg", subdirectory: "owl")!)).with {

                                        $0.debugLayout = true
                                    }

                        ImageView(

                            image: try! Image(
                                
                                contentsOf: Bundle.module.url(
                                    
                                    forResource: "owl-4", withExtension: "jpg", subdirectory: "owl")!)).with {

                                        $0.debugLayout = true
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