//

//

import Foundation
import CustomGraphicsMath

// TODO: maybe put this into another file
// TODO: maybe rename to VirtualRenderTarget
public protocol VirtualScreen {
    var size: DSize2 { get set }

    func delete() throws
}

/// Rendering is relative to topLeft of whatever area the renderer is rendering in.
// TODO: maybe rename to CanvasRenderer/DirectRenderer/SimpleRenderer or something like that
public protocol Renderer {
    //associatedtype VirtualScreen: VisualAppBase.VirtualScreen
    var virtualScreenStack: [VirtualScreen] { get }

    // TODO: maybe resolution belongs to window?
    //var resolution: Double { get }
    func beginFrame() throws
    func endFrame() throws
    func clear(_ color: Color) throws
    func makeVirtualScreen(size: DSize2) throws -> VirtualScreen
    func resizeVirtualScreen(_ screen: inout VirtualScreen, _ size: DSize2) throws
    func pushVirtualScreen(_ screen: VirtualScreen) throws
    @discardableResult func popVirtualScreen() throws -> VirtualScreen?
    func drawVirtualScreens(_ screens: [VirtualScreen], at positions: [DVec2]?) throws
    func beginPath() throws
    func fillColor(_ color: Color) throws
    func fill() throws
    func strokeWidth(_ width: Double) throws
    func strokeColor(_ color: Color) throws
    func stroke() throws
    func rect(_ rect: DRect) throws
    // TODO: update to remove style argument
    func circle(center: DPoint2, radius: Double) throws
    func ellipse(center: DPoint2, radius: DVec2) throws
    func text(_ text: String, topLeft: DPoint2, fontConfig: FontConfig, color: Color) throws
    func lineSegment(from: DPoint2, to: DPoint2) throws
    func getTextBoundsSize(_ text: String, fontConfig: FontConfig) throws -> DSize2
    func multilineText(_ text: String, topLeft: DPoint2, maxWidth: Double, fontConfig: FontConfig, color: Color) throws
    func getMultilineTextBoundsSize(_ text: String, maxWidth: Double, fontConfig: FontConfig) throws -> DSize2
    func globalOpacity(_ opacity: Float) throws
    func clipArea(bounds: DRect) throws
    func releaseClipArea() throws
    func translate(_ translation: DVec2) throws 
    func scale(_ amount: DVec2) throws
    func resetTransform()
}

public extension Renderer {
    func drawVirtualScreens(_ screens: [VirtualScreen], at positions: [DVec2]? = nil) throws {}
}