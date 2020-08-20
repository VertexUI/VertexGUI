/*public struct Config {
    public var id: Int
}



@functionBuilder
struct Builder {
    public func buildExpression(_ subThing: (inout Config) -> String) -> 
}*/

/*
func testFunc(param0: String = "", param1: () -> (), param2: (() -> ())? = nil, param3: (() -> ())? = nil) {
    param1()
}

testFunc {
    print("WOW IT WORKS")
} param2: {
    print("THIS TOO")
}

func testFunc2(params: String...) -> [String] {
    return params
}*/

/*class TestClass {
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

if let test2 = test2, test2 is SomeProto {
    print("IT IS")
}

print(test2Conv)*/