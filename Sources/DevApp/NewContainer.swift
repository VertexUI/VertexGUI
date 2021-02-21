import SwiftGUI

public class NewContainer: ContentfulWidget, SlotAcceptingWidget {
  public static var DefaultSlot = Slot(key: "default", data: Void.self)
  public static var DataSlot = Slot(key: "data", data: String.self)

  let defaultSlot = SlotContentManager(NewContainer.DefaultSlot)
  public var defaultNoDataSlotContentManager: SlotContentManager<Void>? {
    defaultSlot
  }
  let dataSlot = SlotContentManager(NewContainer.DataSlot)

  var _content: ExpDirectContent?

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    defaultSlot()
    dataSlot("THE FIRST DATA SLOT CONTENT")
    dataSlot("THE SECOND DATA SLOT CONTENT")
  }

  override public func getContentBoxConfig() -> BoxConfig {
    BoxConfig(preferredSize: .zero)
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    var size = DSize2.zero
    for child in contentChildren {
      child.layout(constraints: constraints)
      size = child.size
    }
    return constraints.constrain(size)
  }
}