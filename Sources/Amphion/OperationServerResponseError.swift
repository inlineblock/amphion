//
//  OperationServerResponseError.swift
//  
//
//  Created by Dennis Wilkins on 12/21/22.
//

import Foundation

public struct OperationServerResponseError: Decodable {
  struct Location: Decodable {
    let line: UInt;
    let column: UInt;
  }
  
  let message: String;
  let locations: [Location]?;
  let path: [String]?; // i think this should be a string or uint
}
