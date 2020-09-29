import Runtime

public protocol ConfigMarkerProtocol {
    func merged(with partialConfig: Any) -> Any
}

public protocol ConfigProtocol: ConfigMarkerProtocol {
    associatedtype PartialConfig

    /// Fill all the unset properties of partial with the values in default.
    func merged(with partialConfig: PartialConfig?) -> Self
}

public extension ConfigProtocol {
    func merged(with partialConfig: Any) -> Any {
        return merged(with: partialConfig as? PartialConfig)
    }

    func merged(with partialConfig: PartialConfig?) -> Self {
        var result = self

        if let partialConfig = partialConfig {

            let resultTypeInfo = try! Runtime.typeInfo(of: Self.self)
            let partialTypeInfo = try! Runtime.typeInfo(of: PartialConfig.self)

            for resultProperty in resultTypeInfo.properties {
                let partialProperty = try! partialTypeInfo.property(named: resultProperty.name)

                if let value = try! partialProperty.get(from: partialConfig) as Optional<Any> {
                    
                    if let subPartial = value as? PartialConfigMarkerProtocolProtocol {
                        
                        let defaultValue = try! resultProperty.get(from: result)

                        if let defaultSubPartial = defaultValue as? PartialConfigMarkerProtocolProtocol {

                            let subMerged = subPartial.merged(partials: [subPartial, defaultSubPartial])

                            try! resultProperty.set(value: subMerged, on: &result)

                        } else if let defaultSubConfig = defaultValue as? ConfigMarkerProtocol {
                            
                            let subMerged = defaultSubConfig.merged(with: subPartial)
                            
                            try! resultProperty.set(value: subMerged, on: &result)

                        } else {
                            fatalError("Tried to merge incompatible types.")
                        }
                        
                    } else {
                        try! resultProperty.set(value: value, on: &result)
                    }
                }
            }
        }

        return result
    }
}