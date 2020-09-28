/// A Dictionary where the key access is guaranteed to always return a non-optional value (or fail with an error).
public struct DefinitiveDictionary<K: Hashable, V> {

    private var sourceDict: Dictionary<K, V>

    public init(_ sourceDict: Dictionary<K, V>) {

        self.sourceDict = sourceDict
    }

    public subscript(_ key: K) -> V {

        get {

            sourceDict[key]!
        }

        mutating set {

            sourceDict[key] = newValue
        }
    }
}