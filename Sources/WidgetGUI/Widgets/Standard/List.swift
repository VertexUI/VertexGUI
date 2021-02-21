import Foundation
import ReactiveProperties
import VisualAppBase
import GfxMath

private class InternalList: Widget {
  override public func getContentBoxConfig() -> BoxConfig {
    var result = BoxConfig(preferredSize: .zero)
    for child in children {
      if child.boxConfig.preferredSize.width > result.preferredSize.width {
        result.preferredSize.width = child.boxConfig.preferredSize.width
      }
      result.preferredSize.height += child.boxConfig.preferredSize.height

      if child.boxConfig.minSize.width > result.minSize.width {
        result.minSize.width = child.boxConfig.minSize.width
      }
      result.minSize.height += child.boxConfig.minSize.height

      if child.boxConfig.maxSize.width > result.maxSize.width {
        result.maxSize.width = child.boxConfig.maxSize.width
      }
      result.maxSize.height += child.boxConfig.maxSize.height
    }
    return result
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    var currentPosition = DPoint2.zero
    var maxWidth = 0.0

    for child in children {
      let childConstraints = BoxConstraints(minSize: DSize2(constraints.minWidth, 0), maxSize: constraints.maxSize)
      child.layout(constraints: childConstraints)

      child.position = currentPosition

      currentPosition.y += child.height
      if child.width > maxWidth {
        maxWidth = child.width
      }
    }

    return DSize2(maxWidth, currentPosition.y)
  }
}

fileprivate var itemSlots = [ObjectIdentifier: AnySlot]()

public class List<Item: Equatable>: ContentfulWidget, SlotAcceptingWidget {
  @ObservableProperty
  private var items: [Item]
  private var previousItems: [Item] = []

  /*@Reference
  private var itemLayoutContainer: InternalList*/

  public static var itemSlot: Slot<Item> {
    if itemSlots[ObjectIdentifier(Item.self)] == nil {
      itemSlots[ObjectIdentifier(Item.self)] = Slot(key: "default", data: Item.self)
    }
    return itemSlots[ObjectIdentifier(Item.self)]! as! Slot<Item>
  }
  var itemSlotManager = SlotContentManager(List.itemSlot)

  var storedContent = ExpDirectContent(partials: [])
  override public var content: ExpDirectContent {
    storedContent
  }
  private var itemContents: [ExpDirectContent] = [] {
    didSet {
      storedContent.partials = itemContents.map {
        .content($0)
      }
    }
  }

  public init<P: ReactiveProperty>(_ itemsProperty: P) where P.Value == [Item] {
    super.init()
    self.$items.bind(itemsProperty)
    processItemUpdate(old: [], new: items)
  }

  private func processItemUpdate(old: [Item], new: [Item]) {
    var updatedItemContents = [ExpDirectContent]()

    var usedOldIndices = [Int]()

    outer: for newItem in new {
      var foundOldIndex: Int?

      for (oldIndex, oldItem) in old.enumerated() {
        if oldItem == newItem, !usedOldIndices.contains(oldIndex), itemContents.count > oldIndex {
          foundOldIndex = oldIndex
          break
        }
      }

      if let oldIndex = foundOldIndex {
        updatedItemContents.append(itemContents[oldIndex])
        usedOldIndices.append(oldIndex)
      } else {
        updatedItemContents.append(itemSlotManager(newItem))
      }
    }

    itemContents = updatedItemContents 
  }

  override public func getContentBoxConfig() -> BoxConfig {
    var result = BoxConfig(preferredSize: .zero)
    for child in children {
      if child.boxConfig.preferredSize.width > result.preferredSize.width {
        result.preferredSize.width = child.boxConfig.preferredSize.width
      }
      result.preferredSize.height += child.boxConfig.preferredSize.height

      if child.boxConfig.minSize.width > result.minSize.width {
        result.minSize.width = child.boxConfig.minSize.width
      }
      result.minSize.height += child.boxConfig.minSize.height

      if child.boxConfig.maxSize.width > result.maxSize.width {
        result.maxSize.width = child.boxConfig.maxSize.width
      }
      result.maxSize.height += child.boxConfig.maxSize.height
    }
    return result
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    var currentPosition = DPoint2.zero
    var maxWidth = 0.0

    for child in children {
      let childConstraints = BoxConstraints(minSize: DSize2(constraints.minWidth, 0), maxSize: constraints.maxSize)
      child.layout(constraints: childConstraints)

      child.position = currentPosition

      currentPosition.y += child.height
      if child.width > maxWidth {
        maxWidth = child.width
      }
    }

    return DSize2(maxWidth, currentPosition.y)
  }
}