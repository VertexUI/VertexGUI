open class Application {
  let backend: ApplicationBackend

  public init(backend: ApplicationBackend) {
    self.backend = backend
  }
}