import ExperimentalReactiveProperties
import Events

extension Widget {
  @_functionBuilder
  public struct ExperimentalMultiChildContentBuilder {
    public static func buildExpression(_ widget: Widget) -> [Partial] {
      [.widgets([widget])]
    }

    public static func buildExpression(_ style: Experimental.Style) -> [Partial] {
      [.style(style)]
    }

    public static func buildExpression(_ reactiveContent: ReactiveContent) -> [Partial] {
      [.reactive(reactiveContent)]
    }

    public static func buildEither(first: [Partial]) -> [Partial] {
      first
    }

    public static func buildEither(second: [Partial]) -> [Partial] {
      second
    }

    public static func buildBlock(_ partials: Partial...) -> [Partial] {
      partials
    }

    public static func buildBlock(_ partials: [Partial]...) -> [Partial] {
      partials.flatMap { $0 }
    }

    public static func buildFinalResult(_ partials: [Partial]) -> Content {
      Content(partials: partials, associatedStyleScope: Widget.activeStyleScope)
    }

    public enum Partial {
      case style(Experimental.Style)
      case widgets([Widget])
      case reactive(ReactiveContent)
    }

    public class Content {
      public let partials: [Partial]
      public let associatedStyleScope: UInt
      public var styles: [Experimental.Style] = []
      public var widgets: [Widget] = []

      private var reactiveRanges: [Int: (styles: Range<Int>, widgets: Range<Int>)] = [:]

      public let onChanged = EventHandlerManager<Void>()

      public init(partials: [Partial], associatedStyleScope: UInt) {
        self.partials = partials
        self.associatedStyleScope = associatedStyleScope
        
        for (index, partial) in partials.enumerated() {
          switch partial {
          case let .style(style):
            self.styles.append(style)
          case let .widgets(widgets):
            self.widgets.append(contentsOf: widgets)
          case let .reactive(reactiveContent):
            var initialContent: ReactiveContentBuilder.Content? = nil
            Widget.inStyleScope(associatedStyleScope) {
              initialContent = reactiveContent.builder()
            }
            let stylesStartIndex = styles.count
            let widgetsStartIndex = widgets.count
            self.styles.append(contentsOf: initialContent!.styles)
            self.widgets.append(contentsOf: initialContent!.widgets)
            let stylesEndIndex = styles.count
            let widgetsEndIndex = widgets.count
            self.reactiveRanges[index] = (styles: stylesStartIndex..<stylesEndIndex, widgets: widgetsStartIndex..<widgetsEndIndex)

            _ = reactiveContent.onDependenciesChanged { [unowned self] in
              var updatedContent: ReactiveContentBuilder.Content? = nil
              Widget.inStyleScope(associatedStyleScope) {
                updatedContent = reactiveContent.builder()
              }

              let currentRanges = reactiveRanges[index]!
              self.styles.replaceSubrange(currentRanges.styles, with: updatedContent!.styles)
              self.widgets.replaceSubrange(currentRanges.widgets, with: updatedContent!.widgets)

              let stylesDelta = updatedContent!.styles.count - currentRanges.styles.count
              let widgetsDelta = updatedContent!.widgets.count - currentRanges.widgets.count
              reactiveRanges[index] = (
                styles: currentRanges.styles.startIndex..<currentRanges.styles.endIndex + stylesDelta,
                widgets: currentRanges.widgets.startIndex..<currentRanges.widgets.endIndex + widgetsDelta
              )
              updateRanges(after: index, stylesDelta: stylesDelta, widgetsDelta: widgetsDelta)

              onChanged.invokeHandlers()
            }
          }
        }
      }

      private func updateRanges(after updateIndex: Int, stylesDelta: Int, widgetsDelta: Int) {
        for (index, range) in reactiveRanges {
          if index > updateIndex {
            reactiveRanges[index] = (
              styles: range.styles.startIndex + stylesDelta..<(range.styles.endIndex + stylesDelta),
              widgets: range.widgets.startIndex + widgetsDelta..<(range.widgets.endIndex + widgetsDelta)
            )
          }
        }
      }
    }
  }

  public class ReactiveContent {
    public let proxyDependencies: [AnyReactiveProperty]
    public let builder: () -> ReactiveContentBuilder.Content

    public let onDependenciesChanged = EventHandlerManager<Void>()

    public init<P1: ReactiveProperty>(_ dependency: P1, @ReactiveContentBuilder content builder: @escaping () -> ReactiveContentBuilder.Content) {
      let proxyDependency = ObservableProperty<P1.Value>()
      proxyDependency.bind(dependency)
      self.proxyDependencies = [proxyDependency]
      self.builder = builder

      _ = proxyDependency.onHasValueChanged { [unowned self] _ in
        onDependenciesChanged.invokeHandlers()
      }
      _ = proxyDependency.onChanged { [unowned self] _ in
        onDependenciesChanged.invokeHandlers()
      }
    }
  }

  @_functionBuilder
  public struct ReactiveContentBuilder {
    public static func buildExpression(_ widget: Widget) -> [Partial] {
      [.widgets([widget])]
    }

    public static func buildExpression(_ style: Experimental.Style) -> [Partial] {
      [.style(style)]
    }

    public static func buildEither(first: [Partial]) -> [Partial] {
      first
    }

    public static func buildEither(second: [Partial]) -> [Partial] {
      second
    }

    public static func buildBlock(_ partials: Partial...) -> [Partial] {
      partials
    }

    public static func buildBlock(_ partials: [Partial]...) -> [Partial] {
      partials.flatMap { $0 }
    }

    public static func buildFinalResult(_ partials: [Partial]) -> Content {
      var content = Content()
      for partial in partials {
        switch partial {
        case let .style(style):
          content.styles.append(style)
        case let .widgets(widgets):
          content.widgets.append(contentsOf: widgets)
        }
      }
      return content
    }

    public enum Partial {
      case style(Experimental.Style)
      case widgets([Widget])
    }

    public struct Content {
      public var styles: [Experimental.Style] = []
      public var widgets: [Widget] = []
    }
  }
}