extension Widget {

    public final func findParent(_ condition: (_ parent: Parent) throws -> Bool) rethrows -> Parent? {
        var parent: Parent? = self.parent

        while parent != nil {
            if try condition(parent!) {
                return parent
            }

            if let currentParent = parent as? Widget {
                parent = currentParent.parent
            }
        } 

        return nil
    }

    public final func getParent<T>(ofType type: T.Type) -> T? {
        let parents = getParents(ofType: type)
        return parents.count > 0 ? parents[0] : nil
    }

    /// - Returns: all parents of given type, sorted from nearest to farthest
    public final func getParents<T>(ofType type: T.Type) -> [T] {
        var selectedParents = [T]()
        var currentParent: Parent? = self.parent

        while currentParent != nil {
            if let parent = currentParent as? T {
                selectedParents.append(parent)
            }
            
            if let childParent = currentParent! as? Child {
                currentParent = childParent.parent

            } else {
                break
            }
        }

        return selectedParents
    }

    // TODO: might need possibility to return all of type + a method that only returns first + in what order depth first / breadth first
    public final func getChild<W: Widget>(ofType type: W.Type) -> W? {
        for child in children {
            if let child = child as? W {
                return child
            }
        }
        
        for child in children {
            if let result = child.getChild(ofType: type) {
                return result
            }
        }

        return nil
    }

    /**
    Get a child at any depth where the given condition is true. Depth first.
    */
    public final func getChild(where condition: (_ child: Widget) -> Bool) -> Widget? {
        for child in children {
            if condition(child) {
                return child
            } else if let result = child.getChild(where: condition) {
                return result
            }
        }

        return nil
    }

    /// Retrieve a config of a given type from any parent. If there are multiple configs in the hierarchy,
    /// properties get overwritten by deeper nested configs.
    public final func getConfig<Config: PartialConfigProtocol>(ofType type: Config.Type) -> ComputedProperty<Config?> {
        let configProviders = getParents(ofType: ConfigProvider.self)

        // TODO: if the config providers change, because the parent is swapped and child is retained
        // the returned computed property needs to be setup again!

        return ComputedProperty(configProviders.map { $0.$configs.any }) { [unowned self] in
          // need to fetch the providers again, because if using the variable
          // from outside the closure, it will create a strong reference
          // and because the parents also hold references to their children,
          // a retain cycle will be created
          let configProviders = getParents(ofType: ConfigProvider.self)

          let configs = configProviders.compactMap {
              $0.retrieveConfig(ofType: type)
          }

          if configs.count == 0 {
              return nil
          }

          let resultConfig = type.merged(partials: configs)
          return resultConfig
        }
    }
}
