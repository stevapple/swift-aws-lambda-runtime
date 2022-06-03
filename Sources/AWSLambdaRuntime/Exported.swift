@_exported import AWSLambdaRuntimeCore

@_spi(Lambda) import LambdaRuntimeCore

@main
@available(macOS 12.0, *)
struct MyHandler: LambdaHandler {
    typealias Context = AWSLambda.Context
    typealias Event = String
    typealias Output = String

    init(context: Lambda.InitializationContext) async throws {}

    func handle(_ event: String, context: Context) async throws -> String {
        return event
    }
}
