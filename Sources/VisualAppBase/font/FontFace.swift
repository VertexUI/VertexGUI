public struct FontFace {
    public var path: String
    public var weight: FontWeight
    public var style: FontStyle

    public init(path: String, weight: FontWeight, style: FontStyle) {
        self.path = path
        self.weight = weight
        self.style = style
    }
}