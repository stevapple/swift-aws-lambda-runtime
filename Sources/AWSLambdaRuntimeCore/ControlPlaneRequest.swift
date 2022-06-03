//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@_spi(Lambda) import LambdaRuntimeCore
import NIOHTTP1

extension AWSLambda {
    public struct Invocation: LambdaInvocation {
        @_spi(Lambda) public var requestID: String
        @_spi(Lambda) public var deadlineInMillisSinceEpoch: Int64
        @_spi(Lambda) public var invokedFunctionARN: String
        @_spi(Lambda) public var traceID: String
        @_spi(Lambda) public var clientContext: String?
        @_spi(Lambda) public var cognitoIdentity: String?

        init(requestID: String,
             deadlineInMillisSinceEpoch: Int64,
             invokedFunctionARN: String,
             traceID: String,
             clientContext: String?,
             cognitoIdentity: String?) {
            self.requestID = requestID
            self.deadlineInMillisSinceEpoch = deadlineInMillisSinceEpoch
            self.invokedFunctionARN = invokedFunctionARN
            self.traceID = traceID
            self.clientContext = clientContext
            self.cognitoIdentity = cognitoIdentity
        }

        @_spi(Lambda)
        public init(headers: HTTPHeaders) throws {
            guard let requestID = headers.first(name: AmazonHeaders.requestID), !requestID.isEmpty else {
                throw LambdaRuntimeError.invocationHeadMissingRequestID
            }

            guard let deadline = headers.first(name: AmazonHeaders.deadline) else {
                throw LambdaRuntimeError.invocationHeadMissingDeadlineInMillisSinceEpoch
            }
            guard let unixTimeInMilliseconds = Int64(deadline) else {
                throw LambdaRuntimeError.responseHeadInvalidDeadlineValue
            }

            guard let invokedFunctionARN = headers.first(name: AmazonHeaders.invokedFunctionARN) else {
                throw LambdaRuntimeError.invocationHeadMissingFunctionARN
            }

            let traceID = headers.first(name: AmazonHeaders.traceID) ?? "Root=\(AmazonHeaders.generateXRayTraceID());Sampled=0"

            self.init(
                requestID: requestID,
                deadlineInMillisSinceEpoch: unixTimeInMilliseconds,
                invokedFunctionARN: invokedFunctionARN,
                traceID: traceID,
                clientContext: headers["Lambda-Runtime-Client-Context"].first,
                cognitoIdentity: headers["Lambda-Runtime-Cognito-Identity"].first
            )
        }
    }
}
