import Foundation
import GfxMath

// TODO: maybe put this into another file
// TODO: maybe rename to VirtualRenderTarget
public protocol VirtualScreen {
    var size: DSize2 { get set }

    func delete() 
}

public protocol LoadedFill {
    func destroy()
}

/// Rendering is relative to topLeft of whatever area the renderer is rendering in.
// TODO: maybe rename to CanvasRenderer/DirectRenderer/SimpleRenderer or something like that
public protocol Renderer {
    //associatedtype VirtualScreen: VisualAppBase.VirtualScreen
    var virtualScreenStack: [VirtualScreen] { get }

    // TODO: maybe resolution belongs to window?
    //var resolution: Double { get }
    func beginFrame() 

    func endFrame() 

    func clear(_ color: Color) 

    func makeVirtualScreen(size: DSize2)  -> VirtualScreen

    func resizeVirtualScreen(_ screen: inout VirtualScreen, _ size: DSize2) 

    func pushVirtualScreen(_ screen: VirtualScreen) 

    @discardableResult func popVirtualScreen()  -> VirtualScreen?

    func drawVirtualScreens(_ screens: [VirtualScreen], at positions: [DVec2]?) 

    func beginPath() 

    func move(to position: DPoint2)

    func line(to position: DPoint2)

    func arc(center: DPoint2, radius: Double, startAngle: Double, endAngle: Double, direction: Path.Segment.ArcDirection)

    func pathSegment(_ segment: Path.Segment)

    func path(_ path: Path)

    func closePath()

    /**
    Load a fill for being used later. Does not apply the fill to the current graphics.
    */
    func loadFill(_ fill: Fill) -> LoadedFill

    /**
    Set the fill of the current graphics to a previously loaded fill.
    */
    func setFill(_ fill: LoadedFill)

    /**
    Set the fill to a not pre loaded fill.
    Essentialy loadFill(:) and setFill(:) combined in one function for convenience.
    */
    @discardableResult
    func setFill(_ fill: Fill) -> LoadedFill

    /**
    Perform filling of the current graphics with the previously set fill.
    */
    func fill() 

    func strokeWidth(_ width: Double) 

    func strokeColor(_ color: Color) 

    func stroke() 

    func rectangle(_ rect: DRect) 

    func roundedRectangle(_ rect: DRect, cornerRadii: CornerRadii)

    func circle(center: DPoint2, radius: Double)

    func ellipse(_ bounds: DRect) 

    func lineSegment(from: DPoint2, to: DPoint2)
    
    func text(_ text: String, fontConfig: FontConfig, color: Color, topLeft: DPoint2, maxWidth: Double?) 
    
    func getTextBoundsSize(_ text: String, fontConfig: FontConfig, maxWidth: Double?)  -> DSize2
    
    func globalOpacity(_ opacity: Float) 
    
    func clipArea(bounds: DRect) 
    
    func releaseClipArea() 
    
    func translate(_ translation: DVec2)  
    
    func scale(_ amount: DVec2)
    
    func resetTransform()

    /**
    use to clean up caches etc.
    */
    func destroy()
}

public extension Renderer {
    func drawVirtualScreens(_ screens: [VirtualScreen], at positions: [DVec2]? = nil)  {}
}
/*
public enum FillRule {
    case Solid, Hole 
}*/