import Foundation
import VisualAppBase
import CustomGraphicsMath

public class WidgetBus<Message> {
  public private(set) var onMessage = EventHandlerManager<Message>()

  public func publish(_ message: Message) {
    onMessage.invokeHandlers(message)
  }
}

public struct WidgetInspectionMessage {
  public let sender: Widget
  public let content: MessageContent
  public let timestamp: Double

  public init(
    sender: Widget,
    content: MessageContent,
    timestamp: Double = Date.timeIntervalSinceReferenceDate) {
      self.sender = sender
      self.content = content
      self.timestamp = timestamp
  }

  public enum MessageContent {
    case BuildInvalidated
    case BuildStarted
    case BuildFinished
    
    case LayoutInvalidated
    case LayoutBurstThresholdExceeded
    case LayoutingStarted(constraints: BoxConstraints)
    case LayoutingFinished(unconstrainedSize: DSize2, constrainedSize: DSize2)

    case RenderBurstThresholdExceeded
    case RenderingStarted
    case RenderingFinished(duration: Double)
  }
}

public struct WidgetLifecycleMessage {
  public let sender: Widget
  public let content: MessageContent

  public init(sender: Widget, content: MessageContent) {
    self.sender = sender
    self.content = content
  }

  public enum MessageContent {
    case BuildInvalidated
    case BoxConfigInvalidated
    case LayoutInvalidated
    case RenderStateInvalidated
  }
}