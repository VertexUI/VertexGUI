// TODO: maybe rename to something like WindowSpecificContextualized or so, because haveing a context means that something is attached to a system, window (and renderer possibly)
open class Contextualized<S: System<W, R>, W: Window, R: Renderer> {
    public typealias RenderContext = VisualAppBase.RenderContext<S, W, R>

    open var renderContext: RenderContext?

    public init() {}
}