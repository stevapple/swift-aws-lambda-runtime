@_spi(Lambda) import LambdaRuntimeCore
import Dispatch
import NIOPosix

internal enum Consts {
    static let apiPrefix = "/2018-06-01"
    static let invocationURLPrefix = "\(apiPrefix)/runtime/invocation"
    static let getNextInvocationURLSuffix = "/next"
    static let postResponseURLSuffix = "/response"
    static let postErrorURLSuffix = "/error"
    static let postInitErrorURL = "\(apiPrefix)/runtime/init/error"
    static let functionError = "FunctionError"
    static let initializationError = "InitializationError"
}

/// AWS Lambda HTTP Headers, used to populate the `LambdaContext` object.
internal enum AmazonHeaders {
    static let requestID = "Lambda-Runtime-Aws-Request-Id"
    static let traceID = "Lambda-Runtime-Trace-Id"
    static let clientContext = "X-Amz-Client-Context"
    static let cognitoIdentity = "X-Amz-Cognito-Identity"
    static let deadline = "Lambda-Runtime-Deadline-Ms"
    static let invokedFunctionARN = "Lambda-Runtime-Invoked-Function-Arn"
}

extension AmazonHeaders {
    /// Generates (X-Ray) trace ID.
    /// # Trace ID Format
    /// A `trace_id` consists of three numbers separated by hyphens.
    /// For example, `1-58406520-a006649127e371903a2de979`. This includes:
    /// - The version number, that is, 1.
    /// - The time of the original request, in Unix epoch time, in **8 hexadecimal digits**.
    /// For example, 10:00AM December 1st, 2016 PST in epoch time is `1480615200` seconds, or `58406520` in hexadecimal digits.
    /// - A 96-bit identifier for the trace, globally unique, in **24 hexadecimal digits**.
    /// # References
    /// - [Generating trace IDs](https://docs.aws.amazon.com/xray/latest/devguide/xray-api-sendingdata.html#xray-api-traceids)
    /// - [Tracing header](https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-tracingheader)
    internal static func generateXRayTraceID() -> String {
        // The version number, that is, 1.
        let version: UInt = 1
        // The time of the original request, in Unix epoch time, in 8 hexadecimal digits.
        let now = UInt32(DispatchWallTime.now().millisSinceEpoch / 1000)
        let dateValue = String(now, radix: 16, uppercase: false)
        let datePadding = String(repeating: "0", count: max(0, 8 - dateValue.count))
        // A 96-bit identifier for the trace, globally unique, in 24 hexadecimal digits.
        let identifier = String(UInt64.random(in: UInt64.min ... UInt64.max) | 1 << 63, radix: 16, uppercase: false)
            + String(UInt32.random(in: UInt32.min ... UInt32.max) | 1 << 31, radix: 16, uppercase: false)
        return "\(version)-\(datePadding)\(dateValue)-\(identifier)"
    }
}
