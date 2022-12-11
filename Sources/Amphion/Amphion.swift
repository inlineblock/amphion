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

public struct Network {
    private(set) var endpoint: URL;
    private(set) var onRequest: ((URLRequest) -> URLRequest)?;
    private(set) var session: URLSession;
    
    public init(endpoint: URL, onRequest: ((URLRequest) -> URLRequest)?) {
        self.endpoint = endpoint;
        self.onRequest = onRequest;
        self.session = URLSession.shared;
    }
    
    func handleOperation<TResponse, TVariables>(
        operation: Operation<TResponse, TVariables>,
        variables: TVariables?,
        onUpdate: @escaping OperationUpdate<TResponse>
    ) -> Cancellable where TVariables: Codable {
        var request = URLRequest(url: endpoint);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: [
            "query": operation.id ?? operation.text,
            "variables": variables ?? nil,
        ]) else {
            onUpdate(AmphionOperationState.Failed(AmphionError.jsonSerialization));
            return {
                
            };
        }
        request.httpBody = jsonData;
        
        let task = self.session.dataTask(with: self.onRequest != nil ? self.onRequest!(request) : request) { data, response, error in
                DispatchQueue.main.async {
                    guard let _data = data, error == nil else {
                        onUpdate(AmphionOperationState.Failed(AmphionError.networkError(404)));
                        return;
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
    
}

@available(iOS 14, *)
public class Environment: ObservableObject {
    @Published private(set) var network: Network;
    @Published private(set) var store: Store;
    
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

public struct Operation<TResponse, TVariables> where TVariables: Codable {
    private(set) var type: AmphionOperationType;
    private(set) var factory: (String) -> TResponse;
    private(set) var variables: TVariables?;
    private(set) var text: String?;
    private(set) var id: String?;
}

@available(iOS 14, *)
public struct OperationView<TResponse, TVariables, Content>: View where Content: View, TVariables: Codable {
    @EnvironmentObject var environment: Environment;
    
    var operation: Operation<TResponse, TVariables>;
    var variables: TVariables;
    
    var content: (AmphionOperationState<TResponse>) -> Content;
    @State private var state: AmphionOperationState<TResponse> = AmphionOperationState.Loading;
    
    private var cancellable: (() -> Void)?;

    
    public var body: some View {
        return content(self.state).onAppear(perform: self.appear).onDisappear()
    }
    
    func appear() {
        let _cancellable = environment.network.handleOperation(operation: operation, variables: variables) { state in
            self.state = state;
        };
    }
}
