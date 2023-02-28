//
//  gql.swift
//  clouds
//
//  Created by Dennis Wilkins on 12/4/22.
//

import Foundation
import SwiftUI


@propertyWrapper public struct gql {
  public var wrappedValue: String

  public init(wrappedValue: String) {
    self.wrappedValue = wrappedValue
  }
}
