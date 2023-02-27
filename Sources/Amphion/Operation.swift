//
//  Operation.swift
//  
//
//  Created by Dennis Wilkins on 12/21/22.
//

import Foundation

public protocol Operation {
  associatedtype TResponse = Decodable;
  associatedtype TVariables = Encodable;

  var operationName: String { get };
  var type: AmphionOperationType { get };
  func factory(json: Data) throws -> TResponse;
  var variables: TVariables { get };
  var text: String? { get };
  var id: String? { get };
}
