import Foundation
import VisualAppBase
import GfxMath
import Events

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

  /**
  - Returns: a function to break the pipe
  */
  public func pipe(into buffer: MessageBuffer) -> () -> () {
    buffers.append(buffer)
    let bufferId = ObjectIdentifier(buffer)
    return { [weak self] in
      if let self = self {
        self.buffers.removeAll { ObjectIdentifier($0) == bufferId }
      }
    }
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
      if buffer.messages.count <= nextIndex {
        return nil
      } else {
        defer { nextIndex += 1 }
        return buffer.messages[nextIndex]
      }
    }
  }
}

public struct WidgetInspectionMessage: Equatable {
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

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.sender === rhs.sender && lhs.timestamp == rhs.timestamp && lhs.content == rhs.content
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
