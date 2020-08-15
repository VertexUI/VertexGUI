public protocol PartialConfigMarker {}

public protocol PartialConfig: PartialConfigMarker {
    /// - Parameter partials: will be merged with lower index entries overwriting properties of higher index entries
    init(partials: [Self])
}