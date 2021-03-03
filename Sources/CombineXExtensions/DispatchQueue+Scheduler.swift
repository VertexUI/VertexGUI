import CombineX
import Dispatch

extension DispatchQueue: Scheduler {
  public typealias SchedulerOptions = Void

  public var now: SchedulerTimeType {
    SchedulerTimeType(DispatchTime.now())
  }

  public var minimumTolerance: SchedulerTimeType.Stride {
    SchedulerTimeType.Stride(0)
  }

  public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
    fatalError("not implemented")
  }

  public func schedule(
    after date: SchedulerTimeType,
    tolerance: SchedulerTimeType.Stride,
    options: SchedulerOptions?,
    _ action: @escaping () -> Void
  ) {
    fatalError("not implemented")
  }

  public func schedule(
    after date: SchedulerTimeType,
    interval: SchedulerTimeType.Stride,
    tolerance: SchedulerTimeType.Stride,
    options: SchedulerOptions?,
    _ action: @escaping () -> Void
  ) -> Cancellable {
    let timer = DispatchSource.makeTimerSource(queue: self)
    timer.schedule(deadline: date.dispatchTime, repeating: .nanoseconds(interval.magnitude))
    timer.setEventHandler {
      action()
    }
    timer.resume()
    let cancellable = DispatchQueueSchedulerCancellable(timer: timer, action: action)
    return cancellable
  }

  public class DispatchQueueSchedulerCancellable: Cancellable {
    private var timer: DispatchSourceTimer?
    private var action: (() -> Void)?

    public init(timer: DispatchSourceTimer, action: @escaping () -> Void) {
      self.timer = timer
      self.action = action
    }

    public func cancel() {
      timer!.cancel()
      timer = nil
      action = nil
    }
  }

  public struct SchedulerTimeType: Strideable {
    fileprivate var dispatchTime: DispatchTime

    fileprivate init(_ dispatchTime: DispatchTime) {
      self.dispatchTime = dispatchTime
    }

    public func advanced(by stride: Stride) -> SchedulerTimeType {
      Self(dispatchTime + .nanoseconds(stride.magnitude))
    }

    public func distance(to other: Self) -> Stride {
      Stride.nanoseconds(Int(other.dispatchTime.rawValue - dispatchTime.rawValue)) //dispatchTime.distance(to: other.dispatchTime)
    }

    public struct Stride: SchedulerTimeIntervalConvertible, Comparable, SignedNumeric {
      public typealias IntegerLiteralType = Int

      /** in seconds */
      fileprivate var duration: Double
      public var magnitude: Int {
        get {
          return Int(exactly: duration * 1_000_000_000) ?? Int.max
        }
        set { duration = Double(newValue) / 1_000_000_000 }
      }

      fileprivate init(_ duration: Double) {
        self.duration = duration
      }

      public init?<T>(exactly source: T) where T: BinaryInteger {
        self.duration = Double(source) / 1_000_000_000
      }

      public init(integerLiteral: Int) {
        self.duration = Double(integerLiteral) / 1_000_000_000
      }
      
      public static func seconds(_ s: Int) -> Self {
        Self(Double(s))
      }

      public static func seconds(_ s: Double) -> Self {
        Self(s)
      }

      public static func milliseconds(_ ms: Int) -> Self {
        Self(Double(ms) / 1000)
      }

      public static func microseconds(_ us: Int) -> Self {
        Self(Double(us) / 1_000_000)
      }

      public static func nanoseconds(_ ns: Int) -> Self {
        Self(Double(ns) / 1_000_000_000)
      }

      public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.duration == rhs.duration
      }

      public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.duration < rhs.duration
      }

      public mutating func negate() {
        duration = -duration
      }

      public static prefix func - (_ s: Self) -> Self {
        Self(-s.duration)
      }

      public static prefix func + (_ s: Self) -> Self {
        s
      }

      public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.duration + rhs.duration)
      }

      public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.duration - rhs.duration)
      }

      public static func * (lhs: Self, rhs: Self) -> Self {
        lhs * rhs
      }

      public static func *= (lhs: inout Self, rhs: Self) {
        lhs.duration = lhs.duration * rhs.duration
      }
    }
  }
}