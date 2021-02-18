@_functionBuilder
public class SlotWidgetContentBuilder {
  public struct Result {
    var slotContentContainers: [AnySlotContentContainer] = []

    func getContent(for slot: AnySlot) -> AnySlotContentContainer? {
      for container in slotContentContainers {
        if container.anySlot === slot {
          return container
        }
      }
      return nil
    }
  }
}