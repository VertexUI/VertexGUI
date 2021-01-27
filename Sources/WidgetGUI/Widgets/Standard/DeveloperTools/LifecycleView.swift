import ExperimentalReactiveProperties
import GfxMath

public class LifecycleView: Experimental.ComposedWidget {
  private var lifecycleMethodInvocationSignalBuffer: Bus<LifecycleMethodInvocationSignal>.MessageBuffer

  @ExperimentalReactiveProperties.MutableProperty
  private var invocationInfoItems: [LifecycleMethodInvocationSignal] = []

  @ExperimentalReactiveProperties.MutableProperty
  private var methodInvocationCounts: [LifecycleMethod: Int] = LifecycleMethod.allCases.reduce(into: [:]) {
    $0[$1] = 0
  }

  @ExperimentalReactiveProperties.MutableProperty
  private var showMessages: Bool = false

  public init(_ lifecycleMethodInvocationSignalBuffer: Bus<LifecycleMethodInvocationSignal>.MessageBuffer) {
    self.lifecycleMethodInvocationSignalBuffer = lifecycleMethodInvocationSignalBuffer
    super.init()
    _ = self.onDestroy(lifecycleMethodInvocationSignalBuffer.onMessageAdded { [unowned self] in
      invocationInfoItems = lifecycleMethodInvocationSignalBuffer.messages
      switch $0 {
      case let .started(method, _, _, _):
        methodInvocationCounts[method]! += 1
      default:
        break
      }
    })
  }

  override public func performBuild() {
    rootChild = Experimental.Container() { [unowned self] in
      buildStyle()

      Experimental.SimpleColumn {
        buildStatistics()

        Experimental.Button {
          Experimental.Build($showMessages) {
            if showMessages {
              Experimental.Text("hide messages")
            } else {
              Experimental.Text("show messages")
            }
          }
        } onClick: {
          showMessages = !showMessages
        }

        Experimental.Build($showMessages) {
          if showMessages {
            Experimental.List($invocationInfoItems) {
              buildInfo($0)
            }
          } else {
            Space(.zero)
          }
        }
      }
    }
  }

  private func buildStatistics() -> Widget {
    SimpleRow { [unowned self] in
      buildStatistic(for: .layout)
      buildStatistic(for: .render)
      buildStatistic(for: .build)
      buildStatistic(for: .mount)
    }
  }

  private func buildStatistic(for method: LifecycleMethod) -> Widget {
    Experimental.Container(classes: ["method-invocation-count-container"]) { [unowned self] in
      SimpleRow {
        Experimental.Text(String(describing: method))
        Experimental.Text(ComputedProperty(compute: {
          return String(methodInvocationCounts[method]!)
        }, dependencies: [$methodInvocationCounts]))
      }
    }
  }

  private func buildInfo(_ info: Widget.LifecycleMethodInvocationSignal) -> Widget {
    let method: LifecycleMethod
    switch info {
    case let .started(_method, reason, invocationId, timestamp):
      method = _method
    case let .aborted(_method, _, _, _):
      method = _method
    case let .completed(_method, invocationId, timestamp):
      method = _method
    }

    return Experimental.Container(classes: ["info"]) {
      Experimental.SimpleColumn {
        Experimental.Text(classes: ["method-name"], "method \(method)")
      }
    }
  }

  private func buildStyle() -> Experimental.Style {
    Experimental.Style("&", Experimental.Container.self) {
      ($0.backgroundFill, Color.white)

      Experimental.Style(".method-invocation-count-container", Experimental.Container.self) {
        ($0.padding, Insets(all: 16))
      }

      Experimental.Style(".info", Experimental.Container.self) {
        ($0.backgroundFill, Color.white)
        ($0.padding, Insets(all: 8))

        Experimental.Style(".method-name", Experimental.Text.self) {
          ($0.textColor, Color.black)
          ($0.fontSize, 32.0)
        }
      }
    }
  }
}