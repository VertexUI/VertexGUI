import VisualAppBase
import CustomGraphicsMath

public class Border: SingleChildWidget {

    private let borders: Borders

    private var borderSize: DSize2 {

        DSize2(borders.left + borders.right, borders.top + borders.bottom)
    }

    private let color: Color

    private let childBuilder: () -> Widget

    public init(top: Double = 0, right: Double = 0, bottom: Double = 0, left: Double = 0, color: Color, @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.borders = Borders(top: top, right: right, bottom: bottom, left: left)

        self.color = color

        self.childBuilder = childBuilder
    }

    public convenience init(all: Double, color: Color, @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.init(top: all, right: all, bottom: all, left: all, color: color, child: childBuilder)
    }

    override public func buildChild() -> Widget {

        childBuilder()
    }

    override public func getBoxConfig() -> BoxConfig {

        var boxConfig = child.boxConfig

        boxConfig.preferredSize += borderSize 

        boxConfig.minSize += borderSize

        boxConfig.maxSize += borderSize

        return boxConfig
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        var childConstraints = constraints

        childConstraints.minSize -= borderSize

        childConstraints.minSize = max(.zero, childConstraints.minSize)

        childConstraints.maxSize -= borderSize

        childConstraints.maxSize = max(.zero, childConstraints.maxSize)

        child.layout(constraints: childConstraints)

        child.position = DVec2(borders.left, borders.top)

        let ownSize = child.bounds.size + borderSize

        return constraints.constrain(ownSize)
    }

    override public func renderContent() -> RenderObject? {

        RenderObject.Container {

            child.render()

            if borders.top > 0 {

                RenderObject.RenderStyle(fill: FixedRenderValue(.Color(color)), strokeWidth: borders.top, strokeColor: FixedRenderValue(color)) {

                    RenderObject.LineSegment(from: globalBounds.min + DVec2(0, borders.top / 2), to: globalBounds.min + DVec2(bounds.size.width, borders.top / 2))
                }
            }

            if borders.right > 0 {

                RenderObject.RenderStyle(strokeWidth: borders.right, strokeColor: FixedRenderValue(color)) {

                    RenderObject.LineSegment(from: globalBounds.min + DVec2(bounds.width - borders.right / 2, 0), to: globalBounds.min + DVec2(bounds.width - borders.right / 2, bounds.height))
                }
            }

            if borders.bottom > 0 {

                RenderObject.RenderStyle(strokeWidth: borders.bottom, strokeColor: FixedRenderValue(color)) {

                    RenderObject.LineSegment(from: globalBounds.min + DVec2(0, bounds.height - borders.bottom / 2), to: globalBounds.min + DVec2(bounds.width, bounds.height - borders.bottom / 2))
                }
            }

            if borders.left > 0 {

                RenderObject.RenderStyle(strokeWidth: borders.left, strokeColor: FixedRenderValue(color)) {

                    RenderObject.LineSegment(from: globalBounds.min - DVec2(borders.left / 2, 0), to: globalBounds.min + DVec2(-borders.left / 2, bounds.height))
                }
            }
        }
    }
}

extension Border {

    public struct Borders {

        public var top: Double
        
        public var right: Double

        public var bottom: Double

        public var left: Double
    }

/*    public struct Config: ConfigProtocol {

    }*/
}