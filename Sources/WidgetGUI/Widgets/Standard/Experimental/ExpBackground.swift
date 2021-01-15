import VisualAppBase
import GfxMath

extension Experimental {
  public class Background: ComposedWidget, ExperimentalStylableWidget {
    private let childBuilder: () -> Widget

    private var fill: Color {
      stylePropertyValue(StyleKeys.fill, as: Color.self) ?? Color.transparent
    }

    public init(
      configure: ((Experimental.Background) -> ())? = nil,
      @ChildBuilder content contentBuilder: @escaping () -> ChildBuilder.Result) {
        let content = contentBuilder()
        self.childBuilder = content.child
        super.init()
        self.experimentalProvidedStyles.append(contentsOf: content.experimentalStyles)
        if let configure = configure {
          configure(self)
        }
    }
    
    override public func performBuild() {
      rootChild = childBuilder() 
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