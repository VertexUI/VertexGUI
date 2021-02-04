import ExperimentalReactiveProperties
import GfxMath

public class LifecycleView: Experimental.ComposedWidget {
  private var lifecycleMethodInvocationSignalBuffer: Bus<LifecycleMethodInvocationSignal>.MessageBuffer

  @ExperimentalReactiveProperties.ObservableProperty
  private var invocationSignalGroups: [Int: LifecycleMethodInvocationSignalGroup]

  @ExperimentalReactiveProperties.MutableProperty
  private var invocationInfoItems: [LifecycleMethodInvocationSignal] = []

  @ExperimentalReactiveProperties.MutableProperty
  private var methodInvocationCounts: [LifecycleMethod: Int] = LifecycleMethod.allCases.reduce(into: [:]) {
    $0[$1] = 0
  }

  @ExperimentalReactiveProperties.MutableProperty
  private var showSignals: Bool = false
  @ExperimentalReactiveProperties.MutableProperty
  private var showSignalGroups: Bool = false

  public init<P: ReactiveProperty>(
    _ lifecycleMethodInvocationSignalBuffer: Bus<LifecycleMethodInvocationSignal>.MessageBuffer,
    _ invocationSignalGroupsProperty: P) where P.Value == [Int: LifecycleMethodInvocationSignalGroup] {
      self.lifecycleMethodInvocationSignalBuffer = lifecycleMethodInvocationSignalBuffer

      super.init()

      self.$invocationSignalGroups.bind(invocationSignalGroupsProperty)

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

        Experimental.SimpleRow {
          Experimental.Button {
            Experimental.Build($showSignals) {
              if showSignals {
                Experimental.Text("hide signals")
              } else {
                Experimental.Text("show signals")
              }
            }
          }.onClick {
            showSignals = !showSignals
          }

          Experimental.Button {
            Experimental.Build($showSignalGroups) {
              if showSignals {
                Experimental.Text("hide signal groups")
              } else {
                Experimental.Text("show signal groups")
              }
            }
          }.onClick {
            showSignalGroups = !showSignalGroups
          }
        }

        Experimental.Build($showSignals) {
          if showSignals {
            Experimental.List($invocationInfoItems) {
              buildSignal($0)
            }
          } else {
            Space(.zero)
          }
        }

        Experimental.Build($showSignalGroups) {
          if showSignalGroups {
            Experimental.List(ExperimentalReactiveProperties.ComputedProperty(compute: {
              Array(invocationSignalGroups.values)
            }, dependencies: [$invocationSignalGroups])) {
              buildSignalGroup($0)
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
      buildStatistic(for: .mount)
      buildStatistic(for: .build)
      buildStatistic(for: .layout)
      buildStatistic(for: .render)
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

  private func buildSignal(_ signal: Widget.LifecycleMethodInvocationSignal) -> Widget {
    Experimental.Container(classes: ["signal"]) {
      Experimental.SimpleColumn {
        Experimental.Text(classes: ["method-name"], "method \(signal.method)")

        switch signal {
        case let .started(_, _, _, timestamp):
          Experimental.Text("started at: \(timestamp)")
        default:
          Space(.zero)
        }
      }
    }
  }

  private func buildSignalGroup(_ group: Widget.LifecycleMethodInvocationSignalGroup) -> Widget {
    Experimental.Container(classes: ["signal-group"]) { [unowned self] in
      Experimental.SimpleColumn {
        Experimental.Text(classes: ["method-name"], "method \(group.method)")

        group.signals.map {
          buildSignal($0)
        }
      }
    }
  }

  private func buildStyle() -> Experimental.Style {
    Experimental.Style("&", Experimental.Container.self) {
      ($0.backgroundFill, Color.white)

      Experimental.Style(".method-invocation-count-container", Experimental.Container.self) {
        ($0.padding, Insets(all: 16))
      }

      Experimental.Style(".signal", Experimental.Container.self) {
        ($0.backgroundFill, Color.white)
        ($0.padding, Insets(all: 8))

        Experimental.Style(".method-name", Experimental.Text.self) {
          ($0.textColor, Color.black)
          ($0.fontSize, 16.0)
        }
      }

      Experimental.Style(".signal-group", Experimental.Container.self) {
        ($0.backgroundFill, Color.white)
        ($0.padding, Insets(all: 16))
      }
    }
  }
}