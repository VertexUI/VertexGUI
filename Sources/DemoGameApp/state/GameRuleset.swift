import Foundation

public struct GameRuleset {
    /// MassUnits
    public var foodBlobMass: Double = 1

    /// MassUnits
    public var initialPlayerBlobMass: Double = 10

    /// Food per LengthUnit²
    public var minFoodDensity: Double = 1 / 10

    /// Food per TimeUnit
    public var foodGenerationRate: Double = 100 / 1

    /// In LengthUnits per TimeUnit²
    public var frictionDeceleration: Double = 10 / 1

    /// - Returns: LengthUnits
    public var calcRadius = { (mass: Double) in
        sqrt(mass / Double.pi) * 10
    }

    /// - Returns: LengthUnits per TimeUnits²
    public var calcMaxAcceleration = { (mass: Double) in 
        max(150, 300 - 0.01 * mass)
    }

    /// - Returns: LengthUnits per TimeUnits
    public var calcMaxSpeed = { (mass: Double) in
        max(200, 400 - 0.01 * mass)
    }
}