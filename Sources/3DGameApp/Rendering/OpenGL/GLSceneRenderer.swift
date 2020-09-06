import CustomGraphicsMath

public class GLSceneRenderer {

    private let scene: Scene

    public init(scene: Scene) {

        self.scene = scene
    }

    public func setup() {

        GLVoxelRenderer.setup()
    }

    public func render() {

        GLVoxelRenderer.render(voxels: [

            Voxel(position: DVec3(0, 0, 0)),

            //Voxel(position: DVec3(1, 1, 1)),

           // Voxel(position: DVec3(-1, 0, 0))
        ])
    }
}