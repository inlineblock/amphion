//
//  File.swift
//  
//
//  Created by Dennis Wilkins on 2/27/23.
//

import Foundation
import SwiftUI

@propertyWrapper public struct useFragment<TFragment: Fragment>: DynamicProperty where TFragment : Fragment  {
  @ObservedObject public var wrappedValue: TFragment;
  @EnvironmentObject public var environment: Amphion.Environment;
  
  public init(wrappedValue: TFragment) {
    self._wrappedValue = ObservedObject(wrappedValue: wrappedValue);
  }
  
  public mutating func update() {
    _wrappedValue.update()
    if let idable = wrappedValue as? WithId {
      environment.store.attach(id: idable.id);
    }
  }
}
