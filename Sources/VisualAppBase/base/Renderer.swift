//

//

import Foundation
import CustomGraphicsMath

// TODO: maybe put this into another file
public protocol VirtualScreen {

}

/// Rendering is relative to topLeft of whatever area the renderer is rendering in.
// TODO: maybe rename to CanvasRenderer/DirectRenderer/SimpleRenderer or something like that
public protocol Renderer {
    // TODO: implement associated type and type erasure AnyRenderer
    //associatedtype VirtualScreen: VisualAppBase.VirtualScreen

    // TODO: maybe resolution belongs to window?
    //var resolution: Double { get }
    func beginFrame() throws
    func endFrame() throws
    func clear(_ color: Color) throws
    func makeVirtualScreen() throws -> VirtualScreen
    func bindVirtualScreen(_ screen: VirtualScreen) throws
    func unbindVirtualScreen() throws
    func drawVirtualScreens(_ screens: [VirtualScreen]) throws
    func beginPath() throws
    func fillColor(_ color: Color) throws
    func fill() throws
    func strokeWidth(_ width: Double) throws
    func strokeColor(_ color: Color) throws
    func stroke() throws
    func rect(_ rect: DRect) throws
    // TODO: update to remove style argument
    func circle(center: DPoint2, radius: Double, style: RenderStyle) throws
    func ellipse(center: DPoint2, radius: DVec2, style: RenderStyle) throws
    func text(_ text: String, topLeft: DPoint2, fontConfig: FontConfig, color: Color) throws
    func line(from: DPoint2, to: DPoint2, width: Double, color: Color) throws
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