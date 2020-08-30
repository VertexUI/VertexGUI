//

//

import Foundation

public struct Color: Hashable, Equatable {
    public typealias RGB = (r: UInt8, g: UInt8, b: UInt8)
    public typealias RGBA = (r: UInt8, g: UInt8, b: UInt8, a: UInt8)
    public typealias HSL = (h: Double, s: Double, l: Double)
    public typealias HSLA = (h: Double, s: Double, l: Double, a: Double)

    public private(set) var rgb: RGB 
    public private(set) var hsl: HSL

    public private(set) var a: UInt8

    public var r: UInt8 {
        rgb.r
    }
    public var g: UInt8 {
        rgb.g
    }
    public var b: UInt8 {
        rgb.b
    }
    
    public var h: Double {
        hsl.h
    }
    public var s: Double {
        hsl.s
    }
    public var l: Double {
        hsl.l
    }

    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        self.rgb = RGB(r: r, g: g, b: b)
        self.hsl = Color.rgbToHsl(rgb: RGB(r: r, g: g, b: b))
        self.a = a
    }

    public init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
       self.init(r: r, g: g, b: b, a: a)
    }

    /// - Parameters: all in range 0 - 1
    public init(h: Double, s: Double, l: Double, a: Double) {
        self.hsl = HSL(h: h, s: s, l: l)
        self.rgb = Color.hslToRgb(hsl: HSL(h: h, s: s, l: l))
        self.a = UInt8(a * 255)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(r)
        hasher.combine(g)
        hasher.combine(b)
        hasher.combine(a)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b && lhs.a == rhs.a
    }

    public mutating func adjust(alpha: UInt8) {
        self.a = alpha
    }

    public func adjusted(alpha: UInt8) -> Color {
        var result = self
        result.adjust(alpha: alpha)
        return result
    }

    public func lightened(_ percentage: Double) -> Color {
        return Self(h: h, s: s, l: l + l * (percentage / 100), a: Double(a / 255))
    }

    private static func rgbToHsl(rgb: RGB) -> HSL {
        let r = Double(rgb.r) / 255
        let g = Double(rgb.g) / 255
        let b = Double(rgb.b) / 255

        let min = Swift.min(r, g, b)
        let max = Swift.max(r, g, b)

        let l = (max + min) / 2

        let s: Double

        var h: Double

        if max == min {
            s = 0
            h = 0
        } else {
            if l < 0.5 {
                s = (max - min) / (max + min)
            } else {
                s = (max - min) / (2 - max - min)
            }

            if r == max {
                h = (g - b) / (max - min)
            } else if g == max {
                h = 2 + (b - r) / (max - min)
            } else { // when b == max
                h = 4 + (r - g) / (max - min)
            }

            if h < 0 {
                h = h + 6
            }

            h = h * 60

            if h < 0 {
                h += 360
            }
        }

        return HSL(h: h, s: s, l: l)
    }

    private static func hslToRgb(hsl: HSL) -> RGB {
        let r: Double
        let g: Double
        let b: Double

        let tmp1: Double
        let tmp2: Double

        if hsl.s == 0 {
            r = hsl.l
            g = hsl.l
            b = hsl.l
        } else {
            if hsl.l < 0.5 {
                tmp2 = hsl.l * (1 + hsl.s)
            } else {
                tmp2 = hsl.l + hsl.s - hsl.l * hsl.s
            }

            tmp1 = 2 * hsl.l - tmp2

            let h = hsl.h / 360

            var tmpR = h + 1 / 3
            if tmpR > 1 {
                tmpR -= 1
            }
            
            let tmpG = h
            
            var tmpB = h - 1 / 3
            if tmpB < 0 {
                tmpB += 1
            }

            if tmpR < 1 / 6 {
                r = tmp1 + (tmp2 - tmp1) * 6 * tmpR
            } else if tmpR < 0.5 {
                r = tmp2
            } else if tmpR < 2 / 3 {
                r = tmp1 + (tmp2 - tmp1) * (2 / 3 - tmpR) * 6
            } else {
                r = tmp1
            }

            if tmpG < 1 / 6 {
                g = tmp1 + (tmp2 - tmp1) * 6 * tmpG
            } else if tmpG < 0.5 {
                g = tmp2
            } else if tmpG < 2 / 3 {
                g = tmp1 + (tmp2 - tmp1) * (2 / 3 - tmpG) * 6
            } else {
                g = tmp1
            }

            if tmpB < 1 / 6 {
                b = tmp1 + (tmp2 - tmp1) * 6 * tmpB
            } else if tmpB < 0.5 {
                b = tmp2
            } else if tmpB < 2 / 3 {
                b = tmp1 + (tmp2 - tmp1) * (2 / 3 - tmpB) * 6
            } else {
                b = tmp1
            }
        }

        return RGB(r: UInt8(r * 255), g: UInt8(g * 255), b: UInt8(b * 255))
    }

    public static let Red = Color(255, 0, 0, 255)

    public static let Green = Color(0, 255, 0, 255)

    public static let Yellow = Color(255, 255, 0, 255)

    public static let Orange = Color(255, 150, 0, 255)

    public static let Blue = Color(0, 0, 255, 255)

    public static let LightBlue = Color(180, 180, 255, 255)

    public static let Black = Color(0, 0, 0, 255)
    
    public static let Grey = Color(128, 128, 128, 255)

    public static let White = Color(255, 255, 255, 255)

    public static let Transparent = Color(0, 0, 0, 0)
}
