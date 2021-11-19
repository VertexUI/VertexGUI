import GfxMath
import Swim 

extension ERGBColor where Self.DataType: Swim.DataType {
  public func toSwim() -> Swim.Color<RGB, DataType> {
    Swim.Color(r: r, g: g, b: b)
  }

  public func toSwim() -> Swim.Color<RGBA, DataType> where DataType: BinaryInteger {
    Swim.Color(r: r, g: g, b: b, a: 255)
  }

  public func toSwim() -> Swim.Color<RGBA, DataType> where DataType: BinaryFloatingPoint {
    Swim.Color(r: r, g: g, b: b, a: 1)
  }
}

extension ERGBAColor where Self.DataType: Swim.DataType {
  public func toSwim() -> Swim.Color<RGBA, DataType> {
    Swim.Color(r: r, g: g, b: b, a: a)
  }
}