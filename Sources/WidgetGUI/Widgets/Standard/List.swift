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

public class List<Item: Equatable>: ComposedWidget {
  @ObservableProperty
  private var items: [Item]
  private var previousItems: [Item] = []
  private var itemWidgets: [Widget] = []

  @Reference
  private var itemLayoutContainer: InternalList

  private let childBuilder: (Item) -> Widget

  private var firstDisplayedIndex = 0
  private var displayedCount = 0
  
  public init<P: ReactiveProperty>(
    classes: [String]? = nil,
    @StylePropertiesBuilder styleProperties: (AnyDefaultStyleKeys.Type) -> StyleProperties = { _ in [] },
    _ itemsProperty: P,
    @WidgetBuilder child childBuilder: @escaping (Item) -> Widget) where P.Value == Array<Item> {
      self.childBuilder = childBuilder
      super.init()

      if let classes = classes {
        self.classes.append(contentsOf: classes)
      }
      with(styleProperties(AnyDefaultStyleKeys.self))

      self.$items.bind(itemsProperty)
      _ = self.onDestroy(self.$items.onChanged { [unowned self] in
        processItemUpdate(old: $0.old, new: $0.new)
      })
      _ = self.onBuilt { [unowned self] in
        processItemUpdate(old: [], new: items)
      }
      _ = self.onLayoutingFinished { [unowned self] _ in
        updateDisplayedItems()
      }
  }

  private func processItemUpdate(old: [Item], new: [Item]) {
    var updatedItemWidgets = [Widget]()

    var usedOldIndices = [Int]()

    outer: for newItem in new {
      var foundOldIndex: Int?

      for (oldIndex, oldItem) in old.enumerated() {
        if oldItem == newItem, !usedOldIndices.contains(oldIndex), itemWidgets.count > oldIndex {
          foundOldIndex = oldIndex
          break
        }
      }

      if let oldIndex = foundOldIndex {
        updatedItemWidgets.append(itemWidgets[oldIndex])
        usedOldIndices.append(oldIndex)
      } else {
        updatedItemWidgets.append(childBuilder(newItem))
      }
    }

    itemWidgets = updatedItemWidgets

    if mounted {
      itemLayoutContainer.contentChildren = itemWidgets
    }
  }

  override public func performBuild() {
    return //ScrollArea(scrollX: .Never) { [unowned self] in
      rootChild = InternalList().connect(ref: $itemLayoutContainer)
    // }.connect(ref: $scrollArea).onScrollProgressChanged.chain { [unowned self] _ in
    //   updateDisplayedItems()
    // }
  }

  /*override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    //print("EXP LIST LAYOUTING")
    return super.performLayout(constraints: constraints)
  }*/

  private func updateDisplayedItems() {
    //let currentFirstIndex = firstDisplayedIndex

    //let currentScrollOffsets = scrollArea.offsets
    //let currentScrollProgress = scrollArea.scrollProgress

    /*for widget in itemWidgets {
      if widget.y + widget.height >= currentScrollOffsets.y && widget.y <= currentScrollOffsets.y + scrollArea.height {
        widget.visibility = .Visible
      } else {
        widget.visibility = .Hidden
      }
    }*/
  }
}