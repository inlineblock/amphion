//
//  OperationError.swift
//  
//
//  Created by Dennis Wilkins on 12/21/22.
//

public enum OperationError: Error {
    // Throw when an invalid password is entered
    case jsonSerialization

    // Throw when an expected resource is not found
    case jsonDeserialization

    // Throw in all other cases
    case networkError(Int)
}
