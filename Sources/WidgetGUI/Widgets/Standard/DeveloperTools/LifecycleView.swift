import ReactiveProperties
import GfxMath

public class LifecycleView: ComposedWidget {
  private var lifecycleMethodInvocationSignalBuffer: Bus<LifecycleMethodInvocationSignal>.MessageBuffer

  @ObservableProperty
  private var invocationSignalGroups: [Int: LifecycleMethodInvocationSignalGroup]

  @MutableProperty
  private var invocationInfoItems: [LifecycleMethodInvocationSignal] = []

  @MutableProperty
  private var methodInvocationCounts: [LifecycleMethod: Int] = LifecycleMethod.allCases.reduce(into: [:]) {
    $0[$1] = 0
  }

  @MutableProperty
  private var showSignals: Bool = false
  @MutableProperty
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
    rootChild = Container().withContent { [unowned self] _ in

      buildStatistics()

      Button {
        Build($showSignals) {
          if showSignals {
            Text("hide signals")
          } else {
            Text("show signals")
          }
        }
      }.onClick {
        showSignals = !showSignals
      }

      Button {
        Build($showSignalGroups) {
          if showSignals {
            Text("hide signal groups")
          } else {
            Text("show signal groups")
          }
        }
      }.onClick {
        showSignalGroups = !showSignalGroups
      }

      Build($showSignals) {
        if showSignals {
          List($invocationInfoItems).withContent {
            $0.itemSlot {
              buildSignal($0)
            }
          }
        } else {
          Space(.zero)
        }
      }

      Build($showSignalGroups) {
        if showSignalGroups {
          List(ComputedProperty(compute: {
            Array(invocationSignalGroups.values)
          }, dependencies: [$invocationSignalGroups])).withContent {
            $0.itemSlot {
              buildSignalGroup($0)
            }
          }
        } else {
          Space(.zero)
        }
      }
    }
  }

  private func buildStatistics() -> Widget {
    Container().withContent { [unowned self] _ in
      buildStatistic(for: .mount)
      buildStatistic(for: .build)
      buildStatistic(for: .layout)
      buildStatistic(for: .render)
    }
  }

  private func buildStatistic(for method: LifecycleMethod) -> Widget {
    Container().with(classes: ["method-invocation-count-container"]).withContent { [unowned self] _ in
      Text(String(describing: method))
      Text(ComputedProperty(compute: {
        return String(methodInvocationCounts[method]!)
      }, dependencies: [$methodInvocationCounts]))
    }
  }

  private func buildSignal(_ signal: Widget.LifecycleMethodInvocationSignal) -> Widget {
    Container().with(classes: ["signal"]).withContent { _ in
      Text(classes: ["method-name"], "method \(signal.method)")

      switch signal {
      case let .started(_, _, _, timestamp):
        Text("started at: \(timestamp)")
      default:
        Space(.zero)
      }
    }
  }

  private func buildSignalGroup(_ group: Widget.LifecycleMethodInvocationSignalGroup) -> Widget {
    Container().with(classes: ["signal-group"]).withContent { [unowned self] _ in
      Text(classes: ["method-name"], "method \(group.method)")

      /*group.signals.map {
        buildSignal($0)
      }*/
    }
  }

  /*override public func buildStyle() -> Style {
    Style("&", Container.self) {
      ($0.background, Color.white)

      Style(".method-invocation-count-container", Container.self) {
        ($0.padding, Insets(all: 16))
      }

      Style(".signal", Container.self) {
        ($0.background, Color.white)
        ($0.padding, Insets(all: 8))

        Style(".method-name", Text.self) {
          ($0.foreground, Color.black)
          ($0.fontSize, 16.0)
        }
      }

      Style(".signal-group", Container.self) {
        ($0.background, Color.white)
        ($0.padding, Insets(all: 16))
      }
    }
  }*/
}