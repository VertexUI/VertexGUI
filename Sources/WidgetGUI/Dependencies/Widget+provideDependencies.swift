extension Widget {
  public func provide(dependencies: [Dependency]) -> Widget {
    providedDependencies.append(contentsOf: dependencies)
    return self
  }

  public func provide(dependencies: Dependency...) -> Widget {
    provide(dependencies: dependencies)
  }

  public func provide(dependencies: Any...) -> Widget {
    provide(dependencies: dependencies.map { Dependency($0) })
  }
}