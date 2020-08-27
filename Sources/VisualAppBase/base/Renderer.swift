import Foundation
import struct Swim.Image
import enum Swim.RGBA
import CustomGraphicsMath

// TODO: maybe put this into another file
// TODO: maybe rename to VirtualRenderTarget
public protocol VirtualScreen {
    var size: DSize2 { get set }

    func delete() 
}

public protocol LoadedFill {

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
    func moveTo(_ point: DPoint2) 
    func lineTo(_ point: DPoint2) 
    func closePath()
    // TODO: maybe merge fill into one function, given by enum Fill?
    func fillColor(_ color: Color)
    func fillImage(_ image: Image<RGBA, UInt8>, position: DVec2) -> LoadedFill
    /// Reapply a previously loaded fill
    func applyFill(_ fill: LoadedFill)
    func fill() 
    func strokeWidth(_ width: Double) 
    func strokeColor(_ color: Color) 
    func stroke() 
    func rectangle(_ rect: DRect) 
    func roundedRectangle(_ rect: DRect, cornerRadii: CornerRadii)
    func circle(center: DPoint2, radius: Double)
    func ellipse(_ bounds: DRect) 
    func text(_ text: String, fontConfig: FontConfig, color: Color, topLeft: DPoint2) 
    func lineSegment(from: DPoint2, to: DPoint2) 
    func getTextBoundsSize(_ text: String, fontConfig: FontConfig)  -> DSize2
    func multilineText(_ text: String, fontConfig: FontConfig, color: Color, topLeft: DPoint2, maxWidth: Double) 
    func getMultilineTextBoundsSize(_ text: String, fontConfig: FontConfig, maxWidth: Double)  -> DSize2
    func globalOpacity(_ opacity: Float) 
    func clipArea(bounds: DRect) 
    func releaseClipArea() 
    func translate(_ translation: DVec2)  
    func scale(_ amount: DVec2)
    func resetTransform()
}

public extension Renderer {
    func drawVirtualScreens(_ screens: [VirtualScreen], at positions: [DVec2]? = nil)  {}
}
/*
public enum FillRule {
    case Solid, Hole 
}*/