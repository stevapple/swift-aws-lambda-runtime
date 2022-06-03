@_spi(Lambda) public protocol LambdaProvider  {
    associatedtype Invocation: LambdaInvocation
    associatedtype RequestEncoder: ControlPlaneRequestEncoder
    associatedtype Context: ConcreteLambdaContext where Context.Provider == Self
    associatedtype ResponseDecoder: ControlPlaneResponseDecoder where ResponseDecoder.Invocation == Self.Invocation

    static func withLocalServer<Value>(invocationEndpoint: String?, _ body: @escaping () -> Value) throws -> Value
}

@_spi(Lambda)
extension LambdaProvider {
    public static func withLocalServer<Value>(_ body: @escaping () -> Value) throws -> Value {
        try withLocalServer(invocationEndpoint: nil, body)
    }
}
