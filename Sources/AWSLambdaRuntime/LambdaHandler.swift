//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2021 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Dispatch
import NIOCore

// MARK: - LambdaHandler

#if compiler(>=5.5) && canImport(_Concurrency)
/// Strongly typed, processing protocol for a Lambda that takes a user defined `Event` and returns a user defined `Output` async.
public protocol LambdaHandler: EventLoopLambdaHandler {
    /// The Lambda initialization method
    /// Use this method to initialize resources that will be used in every request.
    ///
    /// Examples for this can be HTTP or database clients.
    /// - parameters:
    ///     - context: Runtime `InitializationContext`.
    init(context: Lambda.InitializationContext) async throws

    /// The Lambda handling method
    /// Concrete Lambda handlers implement this method to provide the Lambda functionality.
    ///
    /// - parameters:
    ///     - event: Event of type `Event` representing the event or request.
    ///     - context: Runtime `Context`.
    ///
    /// - Returns: A Lambda result ot type `Output`.
    func handle(_ event: Event, context: Lambda.Context) async throws -> Output
}

extension LambdaHandler {
    public func handle(_ event: Event, context: Lambda.Context) -> EventLoopFuture<Output> {
        let promise = context.eventLoop.makePromise(of: Output.self)
        promise.completeWithTask {
            try await self.handle(event, context: context)
        }
        return promise.futureResult
    }
}

extension LambdaHandler {
    public static func main() {
        _ = Lambda.run(handlerType: Self.self)
    }
}
#endif
