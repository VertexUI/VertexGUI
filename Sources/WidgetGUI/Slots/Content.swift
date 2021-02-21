import Events

public protocol ExpContentProtocol: class {
  associatedtype Partial

  var partials: [Partial] { get set }

  var onChanged: EventHandlerManager<Void> { get }
  var onDestroy: EventHandlerManager<Void> { get }

  init(partials: [Partial])
}

extension ExpContentProtocol {
  func updateReplacementRanges(ranges: [Int: Range<Int>], from startIndex: Int, deltaLength: Int) -> [Int: Range<Int>] {
    var result = ranges
    for (rangeIndex, range) in result {
      if rangeIndex == startIndex {
        result[rangeIndex] = range.lowerBound..<range.upperBound + deltaLength
      } else if rangeIndex > startIndex {
        result[rangeIndex] = range.lowerBound + deltaLength..<range.upperBound + deltaLength
      }
    }
    return result
  }
}

public class ExpContent: EventfulObject {
  public let onChanged = EventHandlerManager<Void>()
  public let onDestroy = EventHandlerManager<Void>()

  deinit {
    onDestroy.invokeHandlers()
    removeAllEventHandlers()
  }
}

public class ExpDirectContent: ExpContent, ExpContentProtocol {
  public var partials: [Partial] = [] {
    didSet {
      resolve()
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
      case let .content(nestedContent):
        let nestedWidgets = nestedContent.widgets

        replacementRanges[index] = widgets.count..<(widgets.count + nestedWidgets.count)

        widgets.append(contentsOf: nestedWidgets)

        nestedHandlerRemovers.append(nestedContent.onChanged { [unowned self] in
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
}

extension ExpDirectContent {
  public enum Partial {
    case widget(Widget)
    case content(ExpDirectContent)
  }
}

public class ExpSlottingContent: ExpContent, ExpContentProtocol {
  public var partials: [Partial] = [] {
    didSet {
      resolve()
    }
  }
  public var slotContentDefinitions = [AnySlotContentDefinition]()
  var replacementRanges = [Int: Range<Int>]()
  var nestedHandlerRemovers = [() -> ()]()
  var directContentPartials: [ExpDirectContent.Partial] = []
  let directContent = ExpDirectContent(partials: [])

  public required init(partials: [Partial]) {
    self.partials = partials
    super.init()
    resolve()
  }

  func resolve() {
    for remove in nestedHandlerRemovers {
      remove()
    }
    slotContentDefinitions = []
    replacementRanges = [:]
    nestedHandlerRemovers = []
    directContentPartials = []

    for (index, partial) in partials.enumerated() {
      switch partial {
      case let .widget(widget):
        directContentPartials.append(.widget(widget))

      case let .directContent(nestedDirectContent):
        directContentPartials.append(.content(nestedDirectContent))

      case let .slotContentDefinition(definition):
        slotContentDefinitions.append(definition)

      case let .slottingContent(nestedSlotContent):
        directContentPartials.append(.content(nestedSlotContent.directContent))

        let nestedDefinitions = nestedSlotContent.slotContentDefinitions

        replacementRanges[index] = slotContentDefinitions.count..<(slotContentDefinitions.count + nestedDefinitions.count)

        slotContentDefinitions.append(contentsOf: nestedDefinitions)

        nestedHandlerRemovers.append(nestedSlotContent.onChanged { [unowned self] in
          let nestedDefinitions = nestedSlotContent.slotContentDefinitions
          self.slotContentDefinitions.replaceSubrange(replacementRanges[index]!, with: nestedDefinitions)

          replacementRanges = updateReplacementRanges(
            ranges: replacementRanges,
            from: index,
            deltaLength: nestedDefinitions.count - replacementRanges[index]!.count)

          onChanged.invokeHandlers()
        })
      }
    }

    directContent.partials = directContentPartials
    onChanged.invokeHandlers()
  }

  public func getSlotContentDefinition(for slot: AnySlot) -> AnySlotContentDefinition? {
    for definition in slotContentDefinitions {
      if definition.anySlot === slot {
        return definition
      }
    }
    return nil
  }
}

extension ExpSlottingContent {
  public enum Partial {
    case widget(Widget)
    case directContent(ExpDirectContent)
    case slotContentDefinition(AnySlotContentDefinition)
    case slottingContent(ExpSlottingContent)
  }
}