public struct GameRules {
    /// Food per LengthUnit².
    public var minFoodDensity: Double = 1 / 30

    /// Food per TimeUnit.
    public var foodGenerationRate: Double = 10 / 1

    /// In LengthUnits per TimeUnit².
    private var frictionDeceleration: Double = 2 / 1

    /// In LengthUnits per TimeUnits²
    public var maxAcceleration: Double = 50
}