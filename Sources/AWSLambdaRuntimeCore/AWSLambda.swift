@_exported import LambdaRuntimeCore

public enum AWSLambda {}

extension AWSLambda: LambdaProvider { }

#if swift(>=5.7) && canImport(_Concurrency)
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public typealias AWSLambdaHandler = LambdaHandler<AWSLambda>
#endif
