@_exported import LambdaRuntimeCore

public enum AWSLambda {}

extension AWSLambda: LambdaProvider {
    public static var runtimeEngineAddress: String? {
        Lambda.env("AWS_LAMBDA_RUNTIME_API")
    }
}

#if swift(>=5.7) && canImport(_Concurrency)
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public typealias AWSLambdaHandler = LambdaHandler<AWSLambda>
#endif
