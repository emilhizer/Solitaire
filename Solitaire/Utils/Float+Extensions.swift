//
//  Float+Extensions.swift
//  Solitaire
//
//  Created by Eric Milhizer on 2/22/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import CoreGraphics


public extension Float {
  /**
   * Converts an angle in degrees to radians.
   */
  public func degreesToRadians() -> Float {
    return Float.pi * self / 180.0
  }
  
  /**
   * Converts an angle in radians to degrees.
   */
  public func radiansToDegrees() -> Float {
    return self * 180.0 / Float.pi
  }
  
  /**
   * Ensures that the float value stays between the given values, inclusive.
   */
  public func clamped(_ v1: Float, _ v2: Float) -> Float {
    let min = v1 < v2 ? v1 : v2
    let max = v1 > v2 ? v1 : v2
    return self < min ? min : (self > max ? max : self)
  }
  
  /**
   * Ensures that the float value stays between the given values, inclusive.
   */
  @discardableResult
  public mutating func clamp(_ v1: Float, _ v2: Float) -> Float {
    self = clamped(v1, v2)
    return self
  }
  
  /**
   * Returns 1.0 if a floating point value is positive; -1.0 if it is negative.
   */
  public func sign() -> Float {
    return (self >= 0.0) ? 1.0 : -1.0
  }
  
  /**
   * Returns a random floating point number between 0.0 and 1.0, inclusive.
   */
  public static func random() -> Float {
    return Float(arc4random()) / 0xFFFFFFFF
  }
  
  /**
   * Returns a random floating point number in the range min...max, inclusive.
   */
  public static func random(min: Float, max: Float) -> Float {
    assert(min < max)
    return Float.random() * (max - min) + min
  }
  
  /**
   * Randomly returns either 1.0 or -1.0.
   */
  public static func randomSign() -> Float {
    return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
  }
}

/**
 * Returns the shortest angle between two angles. The result is always between
 * -Float.pi and Float.pi.
 */
public func shortestAngleBetween(_ angle1: Float, angle2: Float) -> Float {
  let twoπ = Float.pi * 2.0
  var angle = (angle2 - angle1).truncatingRemainder(dividingBy: twoπ)
  if (angle >= Float.pi) {
    angle = angle - twoπ
  }
  if (angle <= -Float.pi) {
    angle = angle + twoπ
  }
  return angle
}
