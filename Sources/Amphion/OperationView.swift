//
//  OperationView.swift
//  
//
//  Created by Dennis Wilkins on 12/21/22.
//

import Foundation
import SwiftUI

typealias OperationUpdate<TResponse> = (AmphionOperationState<TResponse>) -> Void;
typealias Cancellable = () -> Void;

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
