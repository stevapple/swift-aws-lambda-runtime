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

@_exported import AWSLambdaRuntimeCore

#if compiler(>=5.5) && canImport(_Concurrency)
extension Lambda {
    // for testing and internal use
    internal static func run<Handler: LambdaHandler>(configuration: Configuration = .init(), handlerType: Handler.Type) -> Result<Int, Error> {
        self.run(configuration: configuration, factory: { context -> EventLoopFuture<ByteBufferLambdaHandler> in
            let promise = context.eventLoop.makePromise(of: ByteBufferLambdaHandler.self)
            promise.completeWithTask {
                try await Handler(context: context)
            }
            return promise.futureResult
        })
    }
}
#endif
