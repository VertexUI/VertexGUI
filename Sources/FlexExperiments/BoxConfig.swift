import CustomGraphicsMath

fileprivate struct BoxConfig {
    public var preferredSize: DSize2
    public var minSize: DSize2
    public var maxSize: DSize2
    public var aspectRatio: Double? // width / height = aspectRatio

    public init(
        preferredSize: DSize2, 
        minSize: DSize2 = .zero, 
        maxSize: DSize2 = .infinity, 
        aspectRatio: Double? = nil) {
            self.preferredSize = preferredSize
            self.minSize = minSize
            self.maxSize = maxSize
            self.aspectRatio = aspectRatio
    }
}