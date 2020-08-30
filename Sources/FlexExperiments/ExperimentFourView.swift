import Foundation
import WidgetGUI
import CustomGraphicsMath
import ColorizeSwift

public class ExperimentFourView: SingleChildWidget {

    @Observable private var longText: String = "This is the first veeeeeeeeeeeeeeeeeeeeeeeeeeery looooong text"

    override public func buildChild() -> Widget {
        
        Background(color: Color(200, 200, 255, 255)) { [unowned self] in
                
            MouseArea {

                Padding(all: 32) {

                    ConstrainedSize(maxSize: DSize2(500, .infinity)) {

                        Row(wrap: true) {

                            Text("WOW This text is looooooooooooong but doesn't wrap")
                            
                            ObservingBuilder($longText) {
                                
                                ConstrainedSize(minSize: DSize2(100, 0)) {

                                    Text(longText, wrap: true)
                                }
                            }

                            /*Row.Item(grow: 1) {
                                
                                ImageView(

                                    image: try! Image(
                                        
                                        contentsOf: Bundle.module.url(
                                            
                                            forResource: "owl-4", withExtension: "jpg", subdirectory: "owl")!)).with {

                                                $0.debugLayout = true
                                            }
                            }*/

                            Text("This is the text after")

                            Row.Item(grow: 1) {

                                Row {
                                    
                                    Row.Item(grow: 1) {

                                        Background(color: Color(140, 140, 255, 255)) {

                                            Padding(all: 64) {

                                                Text("WORKS")
                                            }
                                            
                                        }.with {

                                            $0.debugLayout = false

                                            $0.layoutDebuggingColor = .Yellow
                                        }
                                    }

                                    Text("A VEEEEEEEEEEEEEEERY LONG TEXT")

                                }.with {

                                    $0.debugLayout = true

                                    $0.layoutDebuggingColor = .LightBlue
                                }
                            }

                            Row.Item(grow: 1) {

                                ConstrainedSize(preferredSize: DSize2(200, 400), minSize: DSize2(200, 400)) {

                                    ImageView(

                                        image: try! Image(
                                            
                                            contentsOf: Bundle.module.url(

                                                forResource: "owl", withExtension: "jpg", subdirectory: "owl")!)).with {

                                                    $0.debugLayout = true
                                                }
                                }
                            }

                            Row.Item(grow: 1) {

                                ConstrainedSize(preferredSize: DSize2(200, 600), minSize: DSize2(200, 600)) {

                                    ImageView(

                                        image: try! Image(
                                            
                                            contentsOf: Bundle.module.url(

                                                forResource: "owl", withExtension: "jpg", subdirectory: "owl")!)).with {

                                                    $0.debugLayout = true
                                                }
                                }
                            }
                        }.with {

                            $0.debugLayout = true
                        }

                    }.with {

                        $0.debugLayout = true
                    }
                }

            } onClick: { [unowned self] in

                switch $0.button {

                case .Left:
                    longText = "This is the second veeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeery looooooooooooooong text that is even longer"

                case .Right:
                    invalidateRenderState()
                }
            }
        }
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