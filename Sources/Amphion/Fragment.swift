//
//  Fragment.swift
//  
//
//  Created by Dennis Wilkins on 12/21/22.
//

import Foundation

open class Fragment: ObservableObject, Decodable {
  
  public init() {
  }
  
}

public protocol WithId: Fragment {
  var id: String { get };
}
