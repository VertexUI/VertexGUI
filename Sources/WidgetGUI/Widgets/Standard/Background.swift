import Foundation
import GfxMath
import VisualAppBase

public final class Background: SingleChildWidget, ConfigurableWidget {
    public static let defaultConfig = Config(fill: .Transparent, shape: .Rectangle)    
    public var localConfig: Config?
    public var localPartialConfig: PartialConfig?
    lazy public var config: Config = combineConfigs()

    private var currentFillRenderValue: AnyRenderValue<Fill>?

    @ComputedProperty
    public var computedConfig: Config

    private var inputChild: Widget

    public init(
        @WidgetBuilder child inputChildBuilder: () -> Widget) {
            self.inputChild = inputChildBuilder()
    }

    public convenience init(
        fill: Color,
        shape: Shape = Shape.Rectangle,
        @WidgetBuilder child inputChildBuilder: () -> Widget) {
            self.init(child: inputChildBuilder)
            with(config: Config(fill: fill, shape: shape))
    }

    override public func addedToParent() {
        _computedConfig = combineConfigsComputed()
        _ = onDestroy(_computedConfig.onChanged { [unowned self] _ in
            invalidateRenderState()
        })
    }

    override public func buildChild() -> Widget {
        inputChild
    }

    override public func renderContent() -> RenderObject? {
        if let fillTransition = computedConfig.fillTransition,
            let previousFillRenderValue = currentFillRenderValue {
                guard case let .Color(previousFill) = previousFillRenderValue.getValue(at: Date.timeIntervalSinceReferenceDate) else {
                    fatalError()
                }

                // need to copy value here because else reference to most recent computed config will be used
                // in getting the previous value
                let targetFill = computedConfig.fill

                currentFillRenderValue = AnyRenderValue(
                    TimedRenderValue(
                        id: 0,
                        startTimestamp: context.applicationTime,
                        duration: fillTransition.duration,
                        valueAt: {
                            Fill.Color(previousFill.mixed(targetFill, $0 * 100))
                        }))

        } else {
            currentFillRenderValue = AnyRenderValue(FixedRenderValue(Fill.Color(computedConfig.fill)))
        }

        return .Container { [unowned self] in
            RenderObject.RenderStyle(fill: currentFillRenderValue!) {
                if case .Rectangle = computedConfig.shape {
                    RenderObject.Rectangle(globalBounds)
                } else if case let .RoundedRectangle(cornerRadii) = computedConfig.shape {
                    RenderObject.Rectangle(globalBounds, cornerRadii: cornerRadii)
                }
            }
            
            child.render()
        }
    }
}

extension Background {
    public struct Config: ConfigProtocol {
        public typealias PartialConfig = Background.PartialConfig
        public var fill: Color
        public var fillTransition: FillTransition?
        public var shape: Shape
    }

    public struct PartialConfig: PartialConfigProtocol {
        public var fill: Color?
        public var fillTransition: FillTransition?
        public var shape: Shape?

        public init() {}
    }

    public enum Shape {
        case Rectangle
        case RoundedRectangle(_ cornerRadii: CornerRadii)
    }

    public struct FillTransition {
        public var duration: Double
        public init(duration: Double) {
            self.duration = duration
        }
    }
}
