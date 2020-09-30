public class Generic<T> {
    public var value: T
    public init(_ value: T) {
        self.value = value
    }
}

protocol Printable {
    var text: String { get }
}

extension Generic: Printable where T == String {

    var text: String {

        return value
    }
}

func printPrintable(_ printable: Printable) {
    print(printable.text)
}

var testVar = Generic("Hello World")

printPrintable(testVar)