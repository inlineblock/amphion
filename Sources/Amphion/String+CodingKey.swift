//
//  String+CodingKey.swift
//  
//
//  Created by Dennis Wilkins on 12/21/22.
//

import Foundation

extension String: CodingKey {
  public var stringValue: String {
    return self;
  }

  /// Creates a new instance from the given string.
  ///
  /// If the string passed as `stringValue` does not correspond to any instance
  /// of this type, the result is `nil`.
  ///
  /// - parameter stringValue: The string value of the desired key.
  public init?(stringValue: String) {
    self = stringValue;
  }

  /// The value to use in an integer-indexed collection (e.g. an int-keyed
  /// dictionary).
  public var intValue: Int? {
    return nil;
  }

  /// Creates a new instance from the specified integer.
  ///
  /// If the value passed as `intValue` does not correspond to any instance of
  /// this type, the result is `nil`.
  ///
  /// - parameter intValue: The integer value of the desired key.
  public init?(intValue: Int) {
    self = String.init(format: "%i", intValue);
  }
}
