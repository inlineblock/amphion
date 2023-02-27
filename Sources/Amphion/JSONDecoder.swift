//
//  File.swift
//  
//
//  Created by Dennis Wilkins on 2/26/23.
//

import Foundation

class AmphionJSONDecoder: JSONDecoder {
  private var store: Store;
  
  public init(store: Store) {
    self.store = store
  }
  
  func decodeWithStore<T>(_ type: T.Type, from data: Data) throws -> T where T : Fragment {
    let result = try! super.decode(type, from: data)
    if let resultWithId = result as? WithId {
      store.attach(id: resultWithId.id)
    }
    return result
  }
}
