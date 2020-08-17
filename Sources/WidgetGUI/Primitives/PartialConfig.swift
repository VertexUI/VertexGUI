import Runtime

public protocol PartialConfigMarker {
    /// - Parameter partials: will be merged with lower index entries overwriting properties of higher index entries
    func merged(partials: [Any]) -> Any
}

public protocol PartialConfig: PartialConfigMarker {
    init()
    
    /// - Parameter partials: will be merged with lower index entries overwriting properties of higher index entries
    init(partials: [Self])

    init(_ modifier: (inout Self) -> ())

    /// - Parameter partials: will be merged with lower index entries overwriting properties of higher index entries
    static func merged(partials: [Self]) -> Self

    /// - Parameter partials: will be merged with lower index entries overwriting properties of higher index entries
    static func merged(partials: [Any]) -> Any

    mutating func callAsFunction(_ modifier: (inout Self) -> ())
}

public extension PartialConfig {
    init(_ modifier: (inout Self) -> ()) {
        self.init()
        modifier(&self)
    }

    static func merged(partials: [Self]) -> Self {
        var instance = try! createInstance(of: Self.self)

        let typeInfo = try! Runtime.typeInfo(of: Self.self)

        var nestedPartials = [String: [Any]]()

        for property in typeInfo.properties {

            for partial in partials {

                if let value = try! property.get(from: partial) as Optional<Any> {

                    if value is PartialConfigMarker {
                        
                        if nestedPartials[property.name] == nil {
                            nestedPartials[property.name] = [Any]()
                        }

                        nestedPartials[property.name]!.append(value)
                        
                    } else {

                        try! property.set(value: value, on: &instance)
                        break
                        
                    }
                }
            }
        } 

        for (propertyName, partials) in nestedPartials {
            let property = try! typeInfo.property(named: propertyName)

            let merged = (partials[0] as! PartialConfigMarker).merged(partials: partials)

            try! property.set(value: merged, on: &instance)
        }

        return instance as! Self
    }

    static func merged(partials: [Any]) -> Any {
        return merged(partials: partials.map { $0 as! Self })
    }

    func merged(partials: [Any]) -> Any {
        return Self.merged(partials: partials)
    }

    init(partials: [Self]) {
        self.init()

        let typeInfo = try! Runtime.typeInfo(of: Self.self)

        for property in typeInfo.properties {
            for partial in partials {
                if let value = try! property.get(from: partial) as Optional<Any> {
                    try! property.set(value: value, on: &self)
                    break
                }
            }
        }
    }

    mutating func callAsFunction(_ modifier: (inout Self) -> ()) {
        modifier(&self)
    }
}