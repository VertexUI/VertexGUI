class Test<T> {
    var myvar: T

    public init(_ val: T) {
        myvar = val

        if self is TestMarker {
            print("CAN RECOGNIZE IT!")
        }
    }
}

protocol TestMarker {

}

extension Test: TestMarker where T: Equatable {
    func printTheTestMarker() {
        print("WOWOWO")
    }
}

class OtherClass {

}

let test1 = Test(OtherClass())