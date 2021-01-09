import VisualAppBase
import GfxMath

extension Experimental {
  public class Background: ComposedWidget, ExperimentalStylableWidget {
    private let childBuilder: () -> ChildBuilder.Result

    private var fill: Color {
      stylePropertyValue(StyleKeys.fill, as: Color.self) ?? Color.transparent
    }

    public init(
      configure: ((Experimental.Background) -> ())? = nil,
      @ChildBuilder child childBuilder: @escaping () -> ChildBuilder.Result) {
        self.childBuilder = childBuilder
        super.init()
        if let configure = configure {
          configure(self)
        }
    }
    
    override public func performBuild() {
      let result = childBuilder()
      rootChild = result.child
      experimentalProvidedStyles.append(contentsOf: result.experimentalStyles)
    }

    override public func renderContent() -> RenderObject? {
      ContainerRenderObject {
        RenderStyleRenderObject(fillColor: fill) {
          RectangleRenderObject(globalBounds)
        }

        rootChild?.render()
      }
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case fill
    }
  }
}