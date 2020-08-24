import Swim

extension Image: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(getData())
        print("HASHING IMAGE!")
    }
}