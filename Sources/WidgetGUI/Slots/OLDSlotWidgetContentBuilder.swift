/*@_functionBuilder
public class SlotWidgetContentBuilder {

  public static func buildExpression(_ container: AnySlotContentContainer) -> [Partial] {
    [.container(container)]
  }
  
  public static func buildExpression(_ widget: Widget) -> [Partial] {
    []
  }

  public static func buildExpression<D>(_ container: SlotContentContainer<D>) -> [Partial] {
    [.container(container)]
  }

  public static func buildBlock(_ partials: [Partial]...) -> [Partial] {
    partials.flatMap { $0 }
  }

  public static func buildFinalResult(_ partials: [Partial]) -> Result {
    var result = Result()
    for partial in partials {
      switch partial {
      case let .container(container): 
        result.slotContentContainers.append(container)
      }
    }
    return result
  }

  public enum Partial {
    case container(AnySlotContentContainer)
  }

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
}*/