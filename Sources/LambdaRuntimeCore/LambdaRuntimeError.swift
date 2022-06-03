//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2022 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@_spi(Lambda) public struct LambdaRuntimeError: Error, Hashable {
    enum Base: Hashable {
        case unsolicitedResponse
        case unexpectedStatusCode

        case responseHeadInvalidStatusLine
        case responseHeadMissingContentLengthOrTransferEncodingChunked
        case responseHeadMoreThan256BytesBeforeCRLF
        case responseHeadHeaderInvalidCharacter
        case responseHeadHeaderMissingColon
        case responseHeadHeaderMissingFieldValue
        case responseHeadInvalidHeader
        case responseHeadInvalidContentLengthValue
        case responseHeadInvalidRequestIDValue
        case responseHeadInvalidTraceIDValue
        case responseHeadInvalidDeadlineValue

        case invocationHeadMissingRequestID
        case invocationHeadMissingDeadlineInMillisSinceEpoch
        case invocationHeadMissingFunctionARN
        case invocationHeadMissingTraceID

        case controlPlaneErrorResponse(ErrorResponse)
    }

    private let base: Base

    private init(_ base: Base) {
        self.base = base
    }

    public static var unsolicitedResponse = LambdaRuntimeError(.unsolicitedResponse)
    public static var unexpectedStatusCode = LambdaRuntimeError(.unexpectedStatusCode)
    public static var responseHeadInvalidStatusLine = LambdaRuntimeError(.responseHeadInvalidStatusLine)
    public static var responseHeadMissingContentLengthOrTransferEncodingChunked =
        LambdaRuntimeError(.responseHeadMissingContentLengthOrTransferEncodingChunked)
    public static var responseHeadMoreThan256BytesBeforeCRLF = LambdaRuntimeError(.responseHeadMoreThan256BytesBeforeCRLF)
    public static var responseHeadHeaderInvalidCharacter = LambdaRuntimeError(.responseHeadHeaderInvalidCharacter)
    public static var responseHeadHeaderMissingColon = LambdaRuntimeError(.responseHeadHeaderMissingColon)
    public static var responseHeadHeaderMissingFieldValue = LambdaRuntimeError(.responseHeadHeaderMissingFieldValue)
    public static var responseHeadInvalidHeader = LambdaRuntimeError(.responseHeadInvalidHeader)
    public static var responseHeadInvalidContentLengthValue = LambdaRuntimeError(.responseHeadInvalidContentLengthValue)
    public static var responseHeadInvalidRequestIDValue = LambdaRuntimeError(.responseHeadInvalidRequestIDValue)
    public static var responseHeadInvalidTraceIDValue = LambdaRuntimeError(.responseHeadInvalidTraceIDValue)
    public static var responseHeadInvalidDeadlineValue = LambdaRuntimeError(.responseHeadInvalidDeadlineValue)

    public static var invocationHeadMissingRequestID = LambdaRuntimeError(.invocationHeadMissingRequestID)
    public static var invocationHeadMissingDeadlineInMillisSinceEpoch = LambdaRuntimeError(.invocationHeadMissingDeadlineInMillisSinceEpoch)
    public static var invocationHeadMissingFunctionARN = LambdaRuntimeError(.invocationHeadMissingFunctionARN)
    public static var invocationHeadMissingTraceID = LambdaRuntimeError(.invocationHeadMissingTraceID)

    public static func controlPlaneErrorResponse(_ response: ErrorResponse) -> Self {
        LambdaRuntimeError(.controlPlaneErrorResponse(response))
    }
}
