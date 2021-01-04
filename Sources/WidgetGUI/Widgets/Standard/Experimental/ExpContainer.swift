import GfxMath

extension Experimental {
  public class Container: ComposedWidget, SimpleStylableWidget {
    private let childBuilder: () -> ChildBuilder.Result 

    public static let defaultStyleProperties = StyleProperties {
      $0.background = .transparent
      $0.padding = Insets(all: 0)
    }
    lazy public private(set) var filledStyleProperties: StyleProperties = getFilledStyleProperties()
    public var directStyleProperties = [AnyStyleProperties]()

    public init(@ChildBuilder child childBuilder: @escaping () -> ChildBuilder.Result) {
      self.childBuilder = childBuilder
    }

    override public func performBuild() {
      let result = childBuilder()
      rootChild = Background() {
        Padding() {
          result.child
        }
      }
      providedStyles.append(contentsOf: result.styles)
    }

    public func acceptsStyleProperties(_ properties: AnyStyleProperties) -> Bool {
      properties is AnyPaddingStyleProperties || properties is AnyBackgroundStyleProperties
    }

    public struct StyleProperties: WidgetGUI.StyleProperties, AnyPaddingStyleProperties, AnyBackgroundStyleProperties {
      @StyleProperty
      public var padding: Insets?
      @StyleProperty
      public var background: Color? 

      public init() {}
    }
  }
}