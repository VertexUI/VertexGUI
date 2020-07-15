class TestClass {
    public init(_ getVals: () -> [String]) {
        print(getVals())
    }
}

let test = TestClass({
    //let a = 21
    //let b = a + 23
    "WOW"
    return ["WSDSDD"]
})

func collectionFunc<S: Sequence>(_ anyStuff: S) {
    print(anyStuff)
}

//collectionFunc(("WOW", "WOW2"))

protocol TestProto {
    associatedtype Val
}

struct ProtoImpl: TestProto {
    typealias Val = String
}

let test2 = ProtoImpl() as Any

let test2Conv = test2 as? some TestProto

print(test2Conv)