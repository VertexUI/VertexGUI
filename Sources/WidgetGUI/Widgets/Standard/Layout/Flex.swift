import CustomGraphicsMath
import VisualAppBase

public class Flex: Widget {

  private let orientation: Orientation
  private let crossAlignment: CrossAlignment
  private let mainAxisVectorIndex: Int
  private let crossAxisVectorIndex: Int
  private let spacing: Double
  internal let wrap: Bool

  private let buildItems: () -> [Item]
  internal var items: [Item] = []

  lazy private var layoutStrategy: LayoutStrategy = chooseLayoutStrategy()

  // TODO: default of crossAlignment = .Stretch slows down computation right now. optimize or change default
  public init(
    orientation: Orientation, crossAlignment: CrossAlignment = .Stretch, spacing: Double = 0,
    wrap: Bool = false, @Flex.ItemBuilder items buildItems: @escaping () -> [Item]
  ) {
    self.orientation = orientation
    self.crossAlignment = crossAlignment

    switch orientation {
    case .Row:
      mainAxisVectorIndex = 0
      crossAxisVectorIndex = 1

    case .Column:
      mainAxisVectorIndex = 1
      crossAxisVectorIndex = 0
    }

    self.buildItems = buildItems
    self.spacing = spacing
    self.wrap = wrap

    super.init()
  }

  /*private func getMainAxisDimension<VectorProtocol: Vector2Protocol>(_ vector: VectorProtocol) -> Double where VectorProtocol.Element == Double {

        return vector.x
    }

    private func getCrossAxisDimension<VectorProtocol: Vector2Protocol>(_ vector: VectorProtocol) -> Double where VectorProtocol.Element == Double {

        return vector.y
    }*/

  override public func build() {
    items = buildItems()
    children = items.map {
      $0.content
    }
  }

  private func chooseLayoutStrategy() -> LayoutStrategy {
    if TwoItemStrategy.test(self) {
      return TwoItemStrategy(self)
    }
    return UniversalStrategy(self)
  }

  // TODO: maybe have box config inside the Widget and then let the parent give the child constraints
  // or maybe one dimension and then the child should decide how to set up the other direction
  override public func getBoxConfig() -> BoxConfig {
    var config = BoxConfig(preferredSize: .zero, minSize: .zero, maxSize: .zero)

    for (index, item) in items.enumerated() {
      let content = item.content
      let contentConfig = content.boxConfig
      let spaceAfter = index < items.count - 1 ? spacing : 0.0

      config.preferredSize[mainAxisVectorIndex] += contentConfig.preferredSize[mainAxisVectorIndex] + spaceAfter
      if config.preferredSize[crossAxisVectorIndex]
        < contentConfig.preferredSize[crossAxisVectorIndex]
      {
        config.preferredSize[crossAxisVectorIndex] =
          contentConfig.preferredSize[crossAxisVectorIndex]
      }

      config.minSize[mainAxisVectorIndex] += contentConfig.minSize[mainAxisVectorIndex] + spaceAfter
      if config.minSize[crossAxisVectorIndex] < contentConfig.minSize[crossAxisVectorIndex] {
        config.minSize[crossAxisVectorIndex] = contentConfig.minSize[crossAxisVectorIndex]
      }

      config.maxSize[mainAxisVectorIndex] += contentConfig.maxSize[mainAxisVectorIndex] + spaceAfter
      if config.maxSize[crossAxisVectorIndex] < contentConfig.maxSize[crossAxisVectorIndex] {
        config.maxSize[crossAxisVectorIndex] = contentConfig.maxSize[crossAxisVectorIndex]
      }
    }

    return config
  }

  // TODO: might create an extra, simpler function that is faster for non-wrapping Flex layouts
  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    return layoutStrategy.layout(constraints: constraints)
  }
}

extension Flex {
  public enum Orientation {
    case Row, Column
  }

  public enum CrossAlignment {
    case Start, Center, End, Stretch
  }

  internal struct Line {
    public var crossAxisStart: Double
    public var size: DSize2 = .zero
    public var items: [Item] = []
    public var totalGrow: Double = 0
    public var totalShrink: Double = 0
  }

  public struct Item {
    public enum FlexValue {
      case Pixels(_ value: Double)
      case Percent(_ value: Double)
    }

    var grow: Double
    var shrink: Double
    var crossAlignment: CrossAlignment?
    var content: Widget
    var width: FlexValue?
    var height: FlexValue?
    var margins: Margins

    public init(
      grow: Double = 0,
      shrink: Double = 1,
      crossAlignment: CrossAlignment? = nil,
      width: FlexValue? = nil,
      height: FlexValue? = nil,
      margins: Margins = Margins(all: 0),
      @WidgetBuilder content contentBuilder: @escaping () -> Widget
    ) {
      self.grow = grow
      self.shrink = shrink
      self.crossAlignment = crossAlignment
      self.width = width
      self.height = height
      self.margins = margins
      self.content = contentBuilder()
    }

    public func getMainAxisSize(_ orientation: Orientation) -> FlexValue? {
      switch orientation {
      case .Row:
        return width
      case .Column:
        return height
      }
    }

    public func getCrossAxisSize(_ orientation: Orientation) -> FlexValue? {
      switch orientation {
      case .Row:
        return height
      case .Column:
        return width
      }
    }

    public func getMainAxisStartMargin(_ orientation: Orientation) -> Double {
      switch orientation {
      case .Row:
        return margins.left
      case .Column:
        return margins.top
      }
    }

    public func getMainAxisEndMargin(_ orientation: Orientation) -> Double {
      switch orientation {
      case .Row:
        return margins.right
      case .Column:
        return margins.bottom
      }
    }

    public func getCrossAxisStartMargin(_ orientation: Orientation) -> Double {
      switch orientation {
      case .Row:
        return margins.top
      case .Column:
        return margins.left
      }
    }

    public func getCrossAxisEndMargin(_ orientation: Orientation) -> Double {
      switch orientation {
      case .Row:
        return margins.bottom
      case .Column:
        return margins.right
      }
    }
  }

  @_functionBuilder
  public struct ItemBuilder {
    public static func buildExpression(_ widget: Widget) -> [Flex.Item] {
      [Flex.Item { widget }]
    }

    public static func buildExpression(_ widgets: [Widget]) -> [Flex.Item] {
      widgets.map { widget in Flex.Item { widget } }
    }

    public static func buildExpression(_ item: Flex.Item) -> [Flex.Item] {
      [item]
    }

    public static func buildExpression(_ items: [Flex.Item]) -> [Flex.Item] {
      items
    }

    public static func buildExpression(_ items: [[Flex.Item]]) -> [Flex.Item] {
      items.flatMap { $0 }
    }

    public static func buildOptional(_ items: [Flex.Item]?) -> [Flex.Item] {
      return items ?? []
    }

    public static func buildEither(first: [Flex.Item]) -> [Flex.Item] {
      return first
    }

    public static func buildEither(second: [Flex.Item]) -> [Flex.Item] {
      return second
    }

    public static func buildBlock(_ items: [Flex.Item]...) -> [Flex.Item] {
      items.flatMap { $0 }
    }

    public static func buildBlock(_ items: [[Flex.Item]]) -> [Flex.Item] {
      items.flatMap { $0 }
    }
  }

  internal class LayoutStrategy {
    unowned var flex: Flex

    var orientation: Orientation {
      flex.orientation
    }
    var crossAlignment: CrossAlignment {
      flex.crossAlignment
    }
    var mainAxisVectorIndex: Int {
      flex.mainAxisVectorIndex
    }
    var crossAxisVectorIndex: Int {
      flex.crossAxisVectorIndex
    }
    var spacing: Double {
      flex.spacing
    }
    var wrap: Bool {
      flex.wrap
    }
    var items: [Item] {
      flex.items
    }

    init(_ flex: Flex) {
      self.flex = flex
    }

    class func test(_ flex: Flex) -> Bool {
      fatalError("test(:) not implemented")
    }

    func layout(constraints: BoxConstraints) -> DSize2 {
      fatalError("layout(:) not implemented")
    }
  }
}