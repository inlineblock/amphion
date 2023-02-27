//
//  Network.swift
//  
//
//  Created by Dennis Wilkins on 12/21/22.
//

import Foundation

struct RequestBody<Variables>: Encodable where Variables: Encodable {
    var operationName: String;
    var query: String;
    var variables: Variables;
}

public struct Network {
    private(set) var endpoint: URL;
    private var onRequest: ((URLRequest) -> URLRequest)?;
    private var session: URLSession;
    
    public init(endpoint: URL, onRequest: ((URLRequest) -> URLRequest)?) {
        self.endpoint = endpoint;
        self.onRequest = onRequest;
        self.session = URLSession.shared;
    }
    
    func handleOperation<TOperation: Operation>(
        operation: TOperation,
        onUpdate: @escaping OperationUpdate<TOperation.TResponse>
    ) -> Cancellable where TOperation.TVariables: Encodable {
        var request = URLRequest(url: endpoint);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "content-type");
        let json = RequestBody(operationName: operation.operationName, query: (operation.id ?? operation.text)!, variables: operation.variables);
        guard let jsonData = try? JSONEncoder().encode(json) else {
            onUpdate(AmphionOperationState.Failed(OperationError.jsonDeserialization));
            return {
                
            };
        }
        request.httpBody = jsonData;
        
        let task = self.session.dataTask(with: self.onRequest != nil ? self.onRequest!(request) : request) { data, response, error in
                DispatchQueue.main.async {
                    if error != nil {
                        onUpdate(AmphionOperationState.Failed(OperationError.networkError(404)));
                    } else if let data = data {
                        if let response = try? operation.factory(json: data) {
                            onUpdate(AmphionOperationState.Complete(response));
                        } else {
                            onUpdate(AmphionOperationState.Failed(OperationError.jsonDeserialization));
                        }
                    } else {
                        onUpdate(AmphionOperationState.Failed(OperationError.networkError(0)));
                    }
                }
            }
            task.resume()
        return {
            task.cancel();
        }
    }
}
