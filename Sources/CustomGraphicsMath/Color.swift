//
// Created by adrian on 03.05.20.
//

import Foundation

public struct Color {
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    public var a: UInt8

    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    public init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
       self.init(r: r, g: g, b: b, a: a)
    }

    public static let Red = Color(255, 0, 0, 255)
    public static let Green = Color(0, 255, 0, 255)
    public static let Blue = Color(0, 0, 255, 255)
    public static let Black = Color(0,0,0,255)
    public static let White = Color(255,255,255,255)
}
