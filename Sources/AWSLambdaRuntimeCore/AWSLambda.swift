@_exported import LambdaRuntimeCore
@_spi(Lambda) import LambdaRuntimeCore

public enum AWSLambda {}

@_spi(Lambda)
extension AWSLambda: LambdaProvider { }
