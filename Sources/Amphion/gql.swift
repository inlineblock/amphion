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

@propertyWrapper public struct useFragment<TFragment: WithId>: DynamicProperty where TFragment : WithId  {
  @StateObject public var wrappedValue: TFragment;
  @EnvironmentObject public var environment: Amphion.Environment;
  
  public init(wrappedValue: TFragment) {
    self._wrappedValue = StateObject(wrappedValue: wrappedValue);
  }
}
