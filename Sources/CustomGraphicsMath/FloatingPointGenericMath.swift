import Foundation

public protocol FloatingPointGenericMath : FloatingPoint {
  static func _log(_ x: Self) -> Self
  static func _sin(_ x: Self) -> Self
  static func _cos(_ x: Self) -> Self
  static func _acos(_ x: Self) -> Self
  static func _tan(_ x: Self) -> Self
  static func _pow(_ x: Self, _ y: Self) -> Self
  // ...
}
extension Float80 : FloatingPointGenericMath {
  public static func _log(_ x: Float80) -> Float80 { return log(x) }
  public static func _sin(_ x: Float80) -> Float80 { return sin(x) }
  public static func _cos(_ x: Float80) -> Float80 { return cos(x) }
  public static func _acos(_ x: Float80) -> Float80 { return acos(x) }
  public static func _tan(_ x: Float80) -> Float80 { return tan(x) }
  public static func _pow(_ x: Float80, _ y: Float80) -> Float80 { return pow(x, y) }
  // ...
}
extension Double : FloatingPointGenericMath {
  public static func _log(_ x: Double) -> Double { return log(x) }
  public static func _sin(_ x: Double) -> Double { return sin(x) }
  public static func _cos(_ x: Double) -> Double { return cos(x) }
  public static func _acos(_ x: Double) -> Double { return acos(x) }
  public static func _tan(_ x: Double) -> Double { return tan(x) }
  public static func _pow(_ x: Double, _ y: Double) -> Double { return pow(x, y) }
  // ...
}
extension Float : FloatingPointGenericMath {
  public static func _log(_ x: Float) -> Float { return log(x) }
  public static func _sin(_ x: Float) -> Float { return sin(x) }
  public static func _cos(_ x: Float) -> Float { return cos(x) }
  public static func _acos(_ x: Float) -> Float { return acos(x) }
  public static func _tan(_ x: Float) -> Float { return tan(x) }
  public static func _pow(_ x: Float, _ y: Float) -> Float { return pow(x, y) }
  // ...
}

public func log<T: FloatingPointGenericMath>(_ x: T) -> T {
  return T._log(x)
}
public func sin<T: FloatingPointGenericMath>(_ x: T) -> T {
  return T._sin(x)
}
public func cos<T: FloatingPointGenericMath>(_ x: T) -> T {
  return T._cos(x)
}
public func acos<T: FloatingPointGenericMath>(_ x: T) -> T {
  return T._acos(x)
}
public func tan<T: FloatingPointGenericMath>(_ x: T) -> T {
  return T._tan(x)
}
public func pow<T: FloatingPointGenericMath>(_ x: T, _ y: T) -> T {
  return T._pow(x, y)
}