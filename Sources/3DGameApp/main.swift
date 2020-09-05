import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import CustomGraphicsMath
import GL

public class ThreeDGameApp: VisualApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow> {

    private var window: Window?

    private let scene = Scene(voxels: [
        Voxel(position: DVec3(0, 0, 0))
    ])

    private let renderer: GLSceneRenderer

    public init() {

        renderer = GLSceneRenderer(scene: scene)

        super.init(system: try! System())

        window = try! Window(background: .Grey, size: DSize2(800, 800))

        renderer.setup()

        _ = system.onFrame(frame)
    }

    private func frame(_ deltaTime: Int) {

        guard let window = window else {

            fatalError("Don't have a window.")
        }

        window.makeCurrent()

        glClearColor(0.2, 0.3, 0.2, 1.0)

        glClear(GLMap.COLOR_BUFFER_BIT)

        renderer.render()

        window.updateContent()
    }
}

let app = ThreeDGameApp()

do {

    try app.start()

} catch {

    print("Error in app.")
}