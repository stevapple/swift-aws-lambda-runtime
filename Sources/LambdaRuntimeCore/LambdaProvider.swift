public protocol LambdaProvider  {
    associatedtype Invocation: LambdaInvocation
    associatedtype RequestEncoder: ControlPlaneRequestEncoder
    associatedtype Context: LambdaContext where Context.Provider == Self
    associatedtype ResponseDecoder: ControlPlaneResponseDecoder where ResponseDecoder.Invocation == Self.Invocation

    @_spi(Lambda)
    static func withLocalServer<Value>(invocationEndpoint: String?, _ body: @escaping () -> Value) throws -> Value
}

@_spi(Lambda)
extension LambdaProvider {
    public static func withLocalServer<Value>(_ body: @escaping () -> Value) throws -> Value {
        try withLocalServer(invocationEndpoint: nil, body)
    }
}
