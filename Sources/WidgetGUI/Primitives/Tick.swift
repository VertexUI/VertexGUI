public struct Tick: Equatable {
    public let deltaTime: Double
    public let totalTime: Double

    public init(deltaTime: Double, totalTime: Double) {
        self.deltaTime = deltaTime
        self.totalTime = totalTime
    }
}