public struct FontFamily {
    public var name: String
    public var faces: [FontFace]

    public init(name: String, faces: [FontFace]) {
        self.name = name
        self.faces = faces
    }
}