import Foundation

public enum AmphionOperationType {
    case Query
    case Mutation
}

public enum AmphionOperationState<TResponse> {
    case Loading
    case Complete(TResponse)
    case Failed(OperationError)
}
