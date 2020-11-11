import Swim

public typealias Image = Swim.Image<RGBA, UInt8>

extension Swim.Image {
  public typealias PixelType = P
  public typealias DataType = T
  public typealias Color = Swim.Color<PixelType, DataType>
}