extension Color {
    
    internal static func rgbToHsl(rgb: RGB) -> HSL {

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

    internal static func hslToRgb(hsl: HSL) -> RGB {
        
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


}