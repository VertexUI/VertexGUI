public protocol Config {
    associatedtype PartialConfig

    init(partial: PartialConfig?, default: Self)
}