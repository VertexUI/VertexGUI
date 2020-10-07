// TODO: maybe rename to something like WindowSpecificContextualized or so, because haveing a context means that something is attached to a system, window (and renderer possibly)
open class Contextualized<S: System, W: Window, R: Renderer> {
    public typealias ApplicationContext = VisualAppBase.ApplicationContext<S, W, R>

    open var renderContext: RenderContext?

    public init() {}
}