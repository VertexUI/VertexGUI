import Foundation
import VisualAppBase
import CustomGraphicsMath

public class WidgetBus<Message> {
  public private(set) var onMessage = EventHandlerManager<Message>()
  private var buffers: [MessageBuffer] = []

  @inline(__always)
  public func publish(_ message: Message) {
    onMessage.invokeHandlers(message)
    for buffer in buffers {
      buffer.append(message)
    }
  }

  @inline(__always)
  public func pipe(into buffer: MessageBuffer) {
    buffers.append(buffer)
  }
}

extension WidgetBus {
  public class MessageBuffer: Sequence {
    public internal(set) var messages: [Message] = []

    public let onUpdated = EventHandlerManager<MessageBuffer>()
    public let onMessageAdded = EventHandlerManager<Message>()

    @inline(__always)
    public func append(_ message: Message) {
      messages.append(message)
      onMessageAdded.invokeHandlers(message)
      onUpdated.invokeHandlers(self)
    }

    @inline(__always)
    public func makeIterator() -> MessageBufferIterator {
      MessageBufferIterator(self)
    }

    @inline(__always)
    public func clear() {
      messages = []
      onUpdated.invokeHandlers(self)
    }
  }

  public struct MessageBufferIterator: IteratorProtocol {
    private var nextIndex = 0
    private let buffer: MessageBuffer

    public init(_ buffer: MessageBuffer)  {
      self.buffer = buffer
    }

    mutating public func next() -> Message? {
      if buffer.messages.count == nextIndex {
        return nil
      } else {
        defer { nextIndex += 1 }
        return buffer.messages[nextIndex]
      }
    }
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

  public enum MessageContent: Hashable {
    case BuildInvalidated
    case BuildStarted
    case BuildFinished
    
    case BoxConfigInvalidated
    
    case LayoutInvalidated
    case LayoutBurstThresholdExceeded
    case LayoutingStarted
    case LayoutingFinished

    case RenderStateInvalidated
    case RenderBurstThresholdExceeded
    case RenderingStarted
    case RenderingFinished
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