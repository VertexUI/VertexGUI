import Foundation
import WidgetGUI
import CustomGraphicsMath
import ColorizeSwift
import VisualAppBase

public class ExperimentFourView: SingleChildWidget {

    @Observable private var longText: String = "This is the first veeeeeeeeeeeeeeeeeeeeeeeeeeery looooong text"

    override public func buildChild() -> Widget {
        
        Row {
        Background(fill: Color(200, 200, 255, 255)) { [unowned self] in

            MouseArea {

                ConstrainedSize(maxSize: DSize2(584, 800)) {

                ScrollArea {

                Padding(all: 32) {

                    ConstrainedSize(maxSize: DSize2(500, .infinity)) {

                        Row(spacing: 0, wrap: true) {

                            Background(fill: .Green) {

                                Space(DSize2(40, 40))
                            }

                            Background(fill: .Red) {

                                Space(DSize2(40, 40))
                            }

                            Row.Item(crossAlignment: .Stretch) {
                                
                                Background(fill: .Blue) {

                                    Space(DSize2(40, 40))
                                }
                            }

                            Column {
                                
                                Column.Item(margins: Margins(top: 20, right: 100, bottom: 60)) {
                                    
                                    Text("First Text in Column")
                                }

                                Text("Second Text in Column")

                                Text("Third Text in Column")

                                Background(fill: .Green) {

                                    Space(DSize2(40, 40))
                                }

                                Background(fill: .Red) {

                                    Space(DSize2(40, 40))
                                }

                                Row.Item(crossAlignment: .Stretch) {
                                    
                                    Background(fill: .Blue) {

                                        Space(DSize2(40, 40))
                                    }
                                }

                            }.with {
                                
                                $0.debugLayout = true
                            }
                            
                            Row.Item(margins: Margins(top: 0, right: 10, bottom: 100, left: 5)) {

                                Text("WOW This text is looooooooooooong but doesn't wrap")
                            }

                            Row.Item(grow: 1, width: .Percent(100)) {

                                ObservingBuilder($longText) {
                                    
                                    ConstrainedSize(minSize: DSize2(100, 0)) {

                                        Text(longText, wrap: true)
                                    }
                                }
                            }

                            Row.Item(grow: 1) {
                                
                                ImageView(

                                    image: try! Image(
                                        
                                        contentsOf: Bundle.module.url(
                                            
                                            forResource: "owl-4", withExtension: "jpg", subdirectory: "owl")!)).with {

                                                $0.debugLayout = true
                                            }
                            }

                            Row.Item(width: .Percent(50), margins: Margins(top: 20, bottom: 60)) {

                                Text("This is the text", wrap: true)
                            }

                            Row.Item(crossAlignment: .Center, width: .Percent(50), margins: Margins(top: 10, bottom: 10)) {

                                Text("This is other text", wrap: true)
                            }

                            Row.Item(grow: 1) {

                                Background(fill: .Yellow) {

                                    Text("Some Text on a background")
                                }
                            }
                            /*Row.Item(grow: 1) {

                                Row {
                                    
                                    Row.Item(grow: 1) {

                                        Background(fill: Color(140, 140, 255, 255)) {

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
                            }*/
                        }

                    }
                }.with {

                    $0.debugLayout = true
                }
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
    }
}