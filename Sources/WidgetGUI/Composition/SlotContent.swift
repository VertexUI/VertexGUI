public class SlotContent: Content, ContentProtocol {
  public var partials: [Partial] = [] {
    didSet {
      if !destroyed {
        resolve()
      }
    }
  }
  public var slotContentDefinitions = [AnySlotContentDefinition]()
  var replacementRanges = [Int: Range<Int>]()
  var nestedHandlerRemovers = [() -> ()]()
  var directContentPartials: [DirectContent.Partial] = []
  let directContent = DirectContent(partials: [])

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

      case let .dynamic(dynamic):
        let nestedSlotContent = dynamic.content

        directContentPartials.append(.content(nestedSlotContent.directContent))

        let nestedDefinitions = nestedSlotContent.slotContentDefinitions

        replacementRanges[index] = slotContentDefinitions.count..<(slotContentDefinitions.count + nestedDefinitions.count)

        slotContentDefinitions.append(contentsOf: nestedDefinitions)

        nestedHandlerRemovers.append(nestedSlotContent.onChanged { [unowned self, unowned nestedSlotContent] in
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

  override public func destroy() {
    super.destroy()

    for remove in nestedHandlerRemovers {
      remove()
    }
    nestedHandlerRemovers = []

    directContentPartials = []
    directContent.destroy()
    slotContentDefinitions = []
    partials = []
  }
}

extension SlotContent {
  public enum Partial {
    case widget(Widget)
    case directContent(DirectContent)
    case slotContentDefinition(AnySlotContentDefinition)
    case dynamic(Dynamic<SlotContent>)
  }
}