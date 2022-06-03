public protocol LambdaProvider  {
    associatedtype Invocation
    associatedtype RequestEncoder: ControlPlaneRequestEncoder
    associatedtype Context: LambdaContext where Context.Invocation == Self.Invocation
    associatedtype ResponseDecoder: ControlPlaneResponseDecoder where ResponseDecoder.Invocation == Self.Invocation

    static var runtimeEngineAddress: String? { get }
#if DEBUG
    @_spi(Lambda)
    static func withLocalServer<Value>(invocationEndpoint: String?, _ body: @escaping () -> Value) throws -> Value
#endif
}

#if DEBUG
@_spi(Lambda)
extension LambdaProvider {
    public static func withLocalServer<Value>(_ body: @escaping () -> Value) throws -> Value {
        try withLocalServer(invocationEndpoint: nil, body)
    }
}
#endif
