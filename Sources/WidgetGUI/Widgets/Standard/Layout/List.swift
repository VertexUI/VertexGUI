import ReactiveProperties

public class List<Item: Equatable>: SingleChildWidget {
  @ObservableProperty
  private var items: [Item]
  private var previousItems: [Item] = []
  private var itemWidgets: [Widget] = []

  @Reference
  private var itemLayoutContainer
  @Reference
  private var scrollArea: ScrollArea

  private let childBuilder: (Item) -> Widget

  private var firstDisplayedIndex = 0
  private var displayedCount = 0
  
  public init(
    _ items: ObservableProperty<[Item]>,
    @WidgetBuilder child childBuilder: @escaping (Item) -> Widget) {
      self._items = items
      self.childBuilder = childBuilder
      super.init()
      _ = self.onDestroy(self.$items.onChanged { [unowned self] _ in
        buildItemWidgets()
      })
      _ = self.onLayoutingFinished { [unowned self] _ in
        updateDisplayedItems()
      }
  }

  private func buildItemWidgets() {
    let previousItemWidgets = itemWidgets
    var updatedItemWidgets = [Widget]()
    let updatedItems = items
    for (index, updatedItem) in updatedItems.enumerated() {
      if previousItems.count > index, updatedItems[index] == previousItems[index] {
        updatedItemWidgets.append(previousItemWidgets[index])
      } else {
        updatedItemWidgets.append(childBuilder(updatedItem))
      }
    }

    itemWidgets = updatedItemWidgets

    invalidateChild()
  }

  override public func buildChild() -> Widget {
    return ScrollArea(scrollX: .Never) { [unowned self] in
      Column {
        itemWidgets.map {
          $0.with {
            $0.visibility = .Visible
          }
        }
      }.connect(ref: $itemLayoutContainer)
    }.connect(ref: $scrollArea).onScrollProgressChanged.chain { [unowned self] _ in
      updateDisplayedItems()
    }
  }

  private func updateDisplayedItems() {
    let currentFirstIndex = firstDisplayedIndex

    let currentScrollOffsets = scrollArea.offsets
    let currentScrollProgress = scrollArea.scrollProgress

    for widget in itemWidgets {
      if widget.y + widget.height >= currentScrollOffsets.y && widget.y <= currentScrollOffsets.y + scrollArea.height {
        widget.visibility = .Visible
      } else {
        widget.visibility = .Hidden
      }
    }
  }
}