public class DirectContent: Content, ContentProtocol {
  public var partials: [Partial] = [] {
    didSet {
      if !destroyed {
        resolve()
      }
    }
  }
  public var widgets: [Widget] = []
  var replacementRanges = [Int: Range<Int>]()

  var nestedHandlerRemovers = [() -> ()]()

  public required init(partials: [Partial]) {
    self.partials = partials
    super.init()
    resolve()
  }

  func resolve() {
    for remove in nestedHandlerRemovers {
      remove()
    }
    widgets = []
    replacementRanges = [:]
    nestedHandlerRemovers = []

    for (index, partial) in partials.enumerated() {
      switch partial {
      case let .widget(widget):
        widgets.append(widget)

      default:
        let nestedContent: DirectContent

        if case let .content(nested) = partial {
          nestedContent = nested
        } else if case let .dynamic(dynamic) = partial {
          nestedContent = dynamic.content
        } else {
          fatalError("unhandled case")
        }

        let nestedWidgets = nestedContent.widgets

        replacementRanges[index] = widgets.count..<(widgets.count + nestedWidgets.count)

        widgets.append(contentsOf: nestedWidgets)

        nestedHandlerRemovers.append(nestedContent.onChanged { [unowned self, unowned nestedContent] in
          let nestedWidgets = nestedContent.widgets
          widgets.replaceSubrange(replacementRanges[index]!, with: nestedWidgets)

          replacementRanges = updateReplacementRanges(
            ranges: replacementRanges,
            from: index,
            deltaLength: nestedWidgets.count - replacementRanges[index]!.count)

          onChanged.invokeHandlers()
        })
      }     
    }

    onChanged.invokeHandlers()
  }

  override public func destroy() {
    super.destroy()
    widgets = []
    partials = []
    for remove in nestedHandlerRemovers {
      remove()
    }
    nestedHandlerRemovers = []
  }
}

extension DirectContent {
  public enum Partial {
    case widget(Widget)
    case content(DirectContent)
    case dynamic(Dynamic<DirectContent>)
  }
}