import GfxMath

public class Button: ContentfulWidget, SlotAcceptingWidgetProtocol {
  public static let defaultSlot = Slot(key: "default", data: Void.self)
  let defaultSlotManager = SlotContentManager(Button.defaultSlot)
  public var defaultNoDataSlotContentManager: SlotContentManager<Void>? {
    defaultSlotManager
  }

  override public var content: DirectContent {
    defaultSlotManager()
  }
}