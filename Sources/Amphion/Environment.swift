//
//  Environment.swift
//  
//
//  Created by Dennis Wilkins on 12/21/22.
//

import Foundation

@available(iOS 14, *)
public class Environment: ObservableObject {
  @Published var network: Network;
  @Published public var store: Store;
  
  public init(network: Network, store: Store) {
      self.network = network;
      self.store = store;
  }
  
}
