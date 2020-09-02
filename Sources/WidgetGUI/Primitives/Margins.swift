public struct Margins {
    
    public var top: Double
    
    public var right: Double
    
    public var bottom: Double
    
    public var left: Double

    public init(top: Double = 0, right: Double = 0, bottom: Double = 0, left: Double = 0) {
        
        self.top = top
        
        self.right = right
        
        self.bottom = bottom
        
        self.left = left
    }

    public init(all: Double) {
        
        self.init(top: all, right: all, bottom: all, left: all)
    }
}