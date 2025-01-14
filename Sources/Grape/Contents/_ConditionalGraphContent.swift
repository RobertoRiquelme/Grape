public struct _ConditionalGraphContent<C1, C2>: GraphContent 
where C1: GraphContent, C2: GraphContent, C1.NodeID == C2.NodeID {
    public typealias NodeID = C1.NodeID

    
    public enum Storage {
        case trueContent(C1)
        case falseContent(C2)
    }

    @usableFromInline
    let storage: Storage
    
    @inlinable
    public init(
        _ storage: Storage
    ) {
        self.storage = storage
    }


    @inlinable
    public var body: _IdentifiableNever<NodeID> {
        _IdentifiableNever<_>()
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        switch storage {
        case .trueContent(let content):
            content._attachToGraphRenderingContext(&context)
        case .falseContent(let content):
            content._attachToGraphRenderingContext(&context)
        }
    }
}