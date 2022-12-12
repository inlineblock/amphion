import Foundation
import SwiftUI

public enum AmphionError: Error {
    // Throw when an invalid password is entered
    case jsonSerialization

    // Throw when an expected resource is not found
    case jsonDeserialization

    // Throw in all other cases
    case networkError(Int)
}

typealias OperationUpdate<TResponse> = (AmphionOperationState<TResponse>) -> Void;
typealias Cancellable = () -> Void;

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
            onUpdate(AmphionOperationState.Failed(AmphionError.jsonDeserialization));
            return {
                
            };
        }
        NSLog(String(data: jsonData, encoding: .utf8)!);
        request.httpBody = jsonData;
        
        let task = self.session.dataTask(with: self.onRequest != nil ? self.onRequest!(request) : request) { data, response, error in
                DispatchQueue.main.async {
                    if error != nil {
                        onUpdate(AmphionOperationState.Failed(AmphionError.networkError(404)));
                    } else if let data = data {
                        if let response = try? operation.factory(json: data) {
                            onUpdate(AmphionOperationState.Complete(response));
                        } else {
                            onUpdate(AmphionOperationState.Failed(AmphionError.jsonDeserialization));
                        }
                    } else {
                        onUpdate(AmphionOperationState.Failed(AmphionError.networkError(0)));
                    }
                }
            }
            task.resume()
        return {
            task.cancel();
        }
    }
}

public struct Store {
    public init() {
        
    }
}

@available(iOS 14, *)
public class Environment: ObservableObject {
    @Published var network: Network;
    @Published var store: Store;
    
    public init(network: Network, store: Store) {
        self.network = network;
        self.store = store;
    }
}

public enum AmphionOperationType {
    case Query
    case Mutation
}

public enum AmphionOperationState<TResponse> {
    case Loading
    case Complete(TResponse)
    case Failed(AmphionError)
}

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

@available(iOS 14, *)
public struct OperationView<TOperation: Operation, TContent: View>: View where TOperation.TVariables: Encodable {
    let operation: TOperation;
    let contentProvider: (AmphionOperationState<TOperation.TResponse>) -> TContent;
    
    public init(operation: TOperation, contentProvider: @escaping (AmphionOperationState<TOperation.TResponse>) -> TContent) {
        self.operation = operation;
        self.contentProvider = contentProvider
    }
    
    public var body: some View {
        return OperationViewImpl<TOperation, TContent>(operation: operation, contentProvider: contentProvider);
    }
}


private struct OperationViewImpl<TOperation: Operation, TContent: View>: View where TOperation.TVariables: Encodable {
    @EnvironmentObject var environment: Environment;

    
    @State private var state: AmphionOperationState<TOperation.TResponse> = AmphionOperationState.Loading;
    @State var cancellable: (() -> Void)?;
    
    let operation: TOperation;
    let contentProvider: (AmphionOperationState<TOperation.TResponse>) -> TContent;
    
    
    public var body: some View {
        return contentProvider(self.state).onAppear(perform: self.appear).onDisappear(perform: self.disappear);
    }
    
    func appear() {
        self.cancellable = environment.network.handleOperation(operation: self.operation) { state in
            self.state = state;
        };
    }
    
    func disappear() {
        if let cancellable = self.cancellable {
            cancellable();
        }
    }
}
