import Foundation
import GfxMath
import OpenCombine
import Drawing

private var itemSlots = [ObjectIdentifier: AnySlot]()

/// Display a list of items.
/// 
/// Widget instances for specific items are constructed using a function passed to a slot. Example:
///
///```swift
///List(items: arrayOfItems).withContent {
/// List<ItemType>.itemSlot { item in
///   Container().withContent {
///     Text(String(describing: item))
///   }
/// }
///}
///```
/// The function passed to .itemSlot is invoked for every item in the given array
/// (although only when the item is or is close to being visible).
///
/// You may pass an ImmutableBinding<[ItemType]> to the List(items:) constructor.
/// When the data in the binding is updated and the ItemType conforms to Equatable,
/// the changed items are determined by
/// checking all items in the old list for equality with items in the new list.
/// When the ItemType does not conform to Equatable, this check cannot be performed.
/// Therefore, the performance will be better if Equatable performance is given.
public class List<Item>: ComposedWidget, SlotAcceptingWidgetProtocol {
  private let compareFunction: ((Item, Item) -> Bool)?

  @ImmutableBinding
  private var items: [Item]
  private var previousItems: [Item] = []

  public static var itemSlot: Slot<Item> {
    let itemTypeId = ObjectIdentifier(Item.self)
    if itemSlots[itemTypeId] == nil {
      itemSlots[itemTypeId] = Slot(key: "default", data: Item.self)
    }
    return itemSlots[itemTypeId] as! Slot<Item>
  }
  let itemSlotManager = SlotContentManager(List.itemSlot)

  var storedContent = DirectContent(partials: [])
  override public var content: DirectContent {
    storedContent
  }
  private var itemContents: [DirectContent] = [] {
    didSet {
      storedContent.partials = itemContents.map {
        .content($0)
      }
    }
  }

  private var itemsSubscription: AnyCancellable?

  public init(items immutableItems: ImmutableBinding<[Item]>) where Item: Equatable {
    self._items = immutableItems
    self.compareFunction = (==)
  }

  public init(items immutableItems: ImmutableBinding<[Item]>) {
    self._items = immutableItems
    self.compareFunction = nil
  }

  public init(items staticItems: [Item]) {
    self._items = ImmutableBinding { staticItems }
    self.compareFunction = nil
  }

  override public func performBuild() {
    itemsSubscription = _items.publisher.sink { [unowned self] in
      processItemUpdate(old: previousItems, new: $0)
      previousItems = $0
    }
    super.performBuild()
  }

  private func processItemUpdate(old: [Item], new: [Item]) {
    var updatedItemContents = [DirectContent]()

    if let compareFunction = compareFunction {
      var usedOldIndices = [Int]()

      outer: for newItem in new {
        var foundOldIndex: Int?

        for (oldIndex, oldItem) in old.enumerated() {
          if compareFunction(oldItem, newItem), !usedOldIndices.contains(oldIndex), itemContents.count > oldIndex {
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
    } else {
      updatedItemContents = new.map { itemSlotManager($0) }
    }

    itemContents = updatedItemContents 

    invalidateLayout()
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