import Foundation
import ReactiveProperties
import VisualAppBase
import GfxMath
import CXShim

fileprivate var itemSlots = [ObjectIdentifier: AnySlot]()

public class List<Item: Equatable>: ContentfulWidget, SlotAcceptingWidgetProtocol {
  @ObservableProperty
  private var items: [Item]

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

  private var ownedImmutableItems: Any?
  private var itemsSubscription: AnyCancellable?

  public init<P: ReactiveProperty>(_ itemsProperty: P) where P.Value == [Item] {
    super.init()
    self.$items.bind(itemsProperty)
    processItemUpdate(old: [], new: items)
    _ = $items.onChanged { [unowned self] in
      processItemUpdate(old: $0.old, new: $0.new)
    }
  }

  public init(items immutableItems: Experimental.ImmutableBinding<[Item]>) {
    super.init()

    self.ownedImmutableItems = immutableItems

    let itemsBackingProperty = MutableProperty<[Item]>(immutableItems.value)
    itemsSubscription = immutableItems.sink {
      itemsBackingProperty.value = $0
    }

    self.$items.bind(itemsBackingProperty)
    _ = $items.onChanged { [unowned self] in
      processItemUpdate(old: $0.old, new: $0.new)
    }

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

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    var currentPosition = DPoint2.zero
    var maxWidth = 0.0

    for child in children {
      let childConstraints = BoxConstraints(minSize: DSize2(constraints.minWidth, 0), maxSize: DSize2(constraints.maxWidth, .infinity))
      // do this comparison to reduce exponential growth of duration
      if childConstraints != child.previousConstraints {
        //print("LIST CURR AND PREV", childConstraints, child.previousConstraints)
        child.layout(constraints: childConstraints)
      }

      child.layoutedPosition = currentPosition

      currentPosition.y += child.layoutedSize.height
      if child.layoutedSize.width > maxWidth {
        maxWidth = child.layoutedSize.width
      }
    }

    return DSize2(maxWidth, currentPosition.y)
  }
}