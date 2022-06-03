@_exported import AWSLambdaRuntimeCore

@main
@available(macOS 12.0, *)
struct MyHandler: LambdaHandler {
    typealias Provider = AWSLambda
    typealias Event = String
    typealias Output = String

    init(context: Lambda.InitializationContext) async throws {}

    func handle(_ event: String, context: Context) async throws -> String {
        return event
    }
}
